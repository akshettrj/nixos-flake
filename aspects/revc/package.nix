{
    lib,
    stdenv,
    cmake,
    pkg-config,
    git,
    makeWrapper,
    glfw,
    libGL,
    libglvnd,
    openal,
    mpg123,
    libx11,
    # reVC engine source tree (with submodules, so vendor/librw is populated).
    # Injected by the local overlay from the `revc_src` flake input.
    revcSrc,
}:

# reVC ("re Vice City") is a from-scratch reimplementation of GTA: Vice City's
# engine. It was removed from nixpkgs after a DMCA takedown, so it is built here
# from a pinned community fork. The build only produces the open-source engine
# plus the project's own overlay `gamefiles/`; the original, proprietary Vice
# City assets are NOT included and must be supplied by the user at runtime (see
# the reVC home aspect for the expected layout).
stdenv.mkDerivation {
    pname = "revc";
    version = "0-unstable-2026-07-01";

    src = revcSrc;

    postPatch = ''
        # The fork uses the C23-only `#elifndef` preprocessor directive, which
        # this toolchain rejects in the project's C++ mode, leaving the POSIX
        # semaphore macros undefined and breaking the build. Use the portable form.
        substituteInPlace src/core/CdStream_posix.cpp \
            --replace-quiet '#elifndef ANDROID' '#elif !defined(ANDROID)'

        # Drop in the persistent "trainer": sticky cheat toggles (infinite
        # health / car health / ammo, never-wanted) plus a vim-navigable
        # overlay panel, and a web remote (nixweb.cpp) that serves a phone UI
        # for the trainer and the whole debug menu over HTTP (port 8766,
        # REVC_WEB_PORT overrides). The CMake source list is a recursive glob,
        # so new files under src/ are compiled automatically.
        #
        # nixweb_bridge.cpp is appended to debugmenu.cpp rather than compiled
        # standalone: it reflects over the Menu/MenuEntry classes that are
        # private to that file.
        #
        # Function-scope extern declarations wire everything in without
        # touching any #include lines:
        #   - poll input, enforce the toggles, and pump the web server every
        #     frame, from CGame::Process (after CPad::UpdatePads refreshes
        #     the pad state)
        #   - draw the panel in the 2D pass, just before CFont::DrawFonts()
        #     flushes the text buffer (anchored on the preceding call)
        cp ${./nixcheats.cpp} src/extras/nixcheats.cpp
        cp ${./nixcheats.h} src/extras/nixcheats.h
        cp ${./nixweb.cpp} src/extras/nixweb.cpp
        cp ${./nixweb.h} src/extras/nixweb.h
        cat ${./nixweb_bridge.cpp} >> src/extras/debugmenu.cpp

        substituteInPlace src/core/Game.cpp \
            --replace-fail 'CPad::UpdatePads();' \
                'CPad::UpdatePads(); extern void NixTrainerInput(void); extern void NixCheatsProcess(void); extern void NixWebProcess(void); NixTrainerInput(); NixCheatsProcess(); NixWebProcess();'

        substituteInPlace src/core/main.cpp \
            --replace-fail 'CPad::PrintErrorMessage();' \
                'CPad::PrintErrorMessage(); extern void NixTrainerRender(void); NixTrainerRender();'
    '';

    nativeBuildInputs = [
        cmake
        pkg-config
        git
        makeWrapper
    ];

    buildInputs = [
        glfw
        libGL
        libglvnd
        openal
        mpg123
        libx11
    ];

    cmakeFlags = [
        # OpenAL audio backend (the MSS backend needs proprietary Miles DLLs).
        "-DREVC_AUDIO=OAL"
        # Emit the install rules (binary + overlay gamefiles).
        "-DREVC_INSTALL=ON"
        # Build the bundled librw renderer instead of hunting for a system one.
        "-DREVC_VENDORED_LIBRW=ON"
        # OpenGL 3 renderer, windowed through GLFW (matches upstream Linux CI).
        "-DLIBRW_PLATFORM=GL3"
        "-DLIBRW_GL3_GFXLIB=GLFW"
        # The web remote (nixweb.cpp) runs its HTTP server on a std::thread.
        "-DCMAKE_CXX_FLAGS=-pthread"
    ];

    enableParallelBuilding = true;

    # Upstream installs the binary and its overlay gamefiles flat into the
    # prefix root (RUNTIME DESTINATION "."). Reshape that into a conventional
    # layout: the engine on PATH, and the overlay gamefiles kept aside so the
    # user can merge them over their own Vice City directory.
    postInstall = ''
        mkdir -p "$out/bin" "$out/share/reVC/gamefiles"

        mv "$out/reVC" "$out/share/reVC/reVC"

        for entry in data models TEXT neo anim audio gamecontrollerdb.txt; do
            if [ -e "$out/$entry" ]; then
                mv "$out/$entry" "$out/share/reVC/gamefiles/"
            fi
        done

        # GLFW resolves libGL (and, under X11, libX11) at runtime via glvnd, so
        # make the GL driver and X11 discoverable to the wrapped binary.
        makeWrapper "$out/share/reVC/reVC" "$out/bin/reVC" \
            --prefix LD_LIBRARY_PATH : "${
                lib.makeLibraryPath [
                    libglvnd
                    libx11
                ]
            }"
    '';

    meta = {
        description = "Reverse-engineered reimplementation of GTA: Vice City (reVC)";
        longDescription = ''
            reVC is an open-source reimplementation of the Grand Theft Auto: Vice
            City game engine. It ships only the engine and the project's overlay
            game files; the original game's proprietary assets are required to
            play and must be provided separately by the user.
        '';
        homepage = "https://github.com/mrxenginner/reVC";
        license = lib.licenses.unfree;
        platforms = lib.platforms.linux;
        mainProgram = "reVC";
    };
}
