{
  programs.yt-dlp = {
    enable = true;
    settings = {
      format = "251";
      extract-audio = true;
      concurrent-fragments = "8";
      output = "~/Nextcloud/Music/%(artist)s/%(album)s/%(track)s.%(ext)s";
      no-mtime = true;
      replace-in-metadata = "artist ',.+' ''";
      embed-metadata = true;
      embed-thumbnail = true;
      convert-thumbnails = "jpg";
    };
    extraConfig = ''
      --ppa "ThumbnailsConvertor+ffmpeg:-c:v mjpeg -vf crop=if(gt(ih,iw),iw,ih):if(gt(iw,ih),ih,iw)"
      --parse-metadata "playlist_index:%(track_number)s"
      --parse-metadata "%(release_year|)s:%(meta_date)s"
      --parse-metadata "track:(?i)(?P<track>.+)\s+(?:\([^)]*(?:master|edition|original)[^)]*\))\s*"
      --parse-metadata "album:(?i)(?P<album>.+)\s+(?:\([^)]*(?:master|edition)[^)]*\))\s*"
    '';
  };
}
