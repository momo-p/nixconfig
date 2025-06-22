{
  pkgs,
  config,
  ...
}: {
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      autoload
      sponsorblock
      mpv-webm
      # autosubsync-mpv
      eisa01.smart-copy-paste-2
    ];
    scriptOpts = {
      webm = {
        output_directory = "${config.home.homeDirectory}/Videos";
      };
      "SmartCopyPaste_II" = {
        linux_copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        linux_paste = "${pkgs.wl-clipboard}/bin/wl-paste";
      };
    };
    config = {
      keep-open = true;
      fullscreen = true;
      save-position-on-quit = true;

      # video
      alang = "ja,jp";
      slang = "enm,nm,eng";
      profile = "high-quality";
      hwdec = "auto";
      vo = "gpu,libmpv";

      # subtitles
      sub-auto = "fuzzy";
      sub-file-paths = "${config.home.homeDirectory}/Downloads";
      sub-fix-timing = true;
      demuxer-mkv-subtitle-preroll = true;

      # audio
      ao = "pulse";
      volume = 80;

      # screenshot
      screenshot-format = "png";
      screenshot-png-compression = 2;
      screenshot-directory = "${config.home.homeDirectory}/Pictures/mpv";

      # yt-dlp
      ytdl-format = "bestvideo+bestaudio";

      input-ipc-server = "/tmp/mpv";
    };
  };
}
