{
  programs.yt-dlp = {
    enable = true;
    settings = {
      format = "251";
      extract-audio = true;
      audio-format = "opus";
      audio-quality = "0";
      concurrent-fragments = "8";

      output = "~/Nextcloud/Music/%(artist,uploader|Unknown)s/%(album,playlist_title|Unknown)s/%(track,title|Unknown)s.%(ext)s";

      no-mtime = true;
      replace-in-metadata = "artist ',.+' ''";
      embed-metadata = true;
      embed-thumbnail = true;
      convert-thumbnails = "jpg";

      sponsorblock-remove = "music_offtopic";
    };
    extraConfig = ''
      --ppa "ThumbnailsConvertor+ffmpeg:-c:v mjpeg -vf crop=ih:ih"
      --parse-metadata "playlist_index:%(track_number)s"
      --parse-metadata "%(release_year|)s:%(meta_date)s"
      --parse-metadata "track:(?i)(?P<track>.+)\s+(?:\([^)]*(?:master|edition|original)[^)]*\))\s*"
      --parse-metadata "album:(?i)(?P<album>.+)\s+(?:\([^)]*(?:master|edition)[^)]*\))\s*"
    '';
  };
}
