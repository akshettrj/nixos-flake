---
name: music-manager
description: "Downloads and Tags new music files"
---
<MUSIC_MANAGER_SKILL>
When provided with a music URL (e.g. from YouTube), download the music file (in the current directory where the agent is running; you will have to specify the whole path) using the tools provided in the `personal_py` MCP server and tag it appropriately.
First use the metadata tool, then the download_music tool. Then using the ID3 tagging tools, add appropriate ID3 tags including link tag which stores the original URL. You can use the web search tool for resolving the title, artist, album etc. The final file name should be just the title of the music.
Note: Do not parallelise the id3 tag tools

The thumbnail will already be present from the download_music tool because it already embeds the thumbnail from YouTube links
The album name should not contain the song name again

If the link provided is a playlist. Then download only the music not already present in the current directory.

Always use the internet search to try to get the actual artists and albums of the songs.

<CLASSICAL>
If the song is a classical song like Ustad Nusrat Fateh Ali Khan's qawwali, then you will omit the album unless you are downloading a playlist of a whole show of NFAK (whose name will be present in the playlist name). In that case, the album name will contain both, the name of the location where the performance happened. and year if present.

Musicians like NFAK have various versions of the same songs, so web search will not give you good results.
<CLASSICAL/>
</MUSIC_MANAGER_SKILL>
