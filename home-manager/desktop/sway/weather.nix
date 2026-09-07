{
  config,
  pkgs,
  ...
}: let
  # derived from time.timeZone on this host
  latitude = "10.8231";
  longitude = "106.6297";

  cache = "${config.xdg.cacheHome}/weather.json";

  fetch = pkgs.writeShellScript "weather-fetch" ''
    set -eu
    url="https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,weather_code&hourly=temperature_2m,precipitation,precipitation_probability&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum&timezone=auto&forecast_days=10"

    tmp=$(${pkgs.coreutils}/bin/mktemp)
    ${pkgs.coreutils}/bin/chmod 644 "$tmp"
    trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT

    ${pkgs.curl}/bin/curl -fsS --max-time 20 "$url" \
      | ${pkgs.jq}/bin/jq -c '
          def jp: {
            "0":"快晴","1":"晴れ","2":"晴れ時々曇り","3":"曇り",
            "45":"霧","48":"霧",
            "51":"霧雨","53":"霧雨","55":"霧雨",
            "61":"小雨","63":"雨","65":"大雨",
            "71":"小雪","73":"雪","75":"大雪","77":"霧雪",
            "80":"にわか雨","81":"にわか雨","82":"激しいにわか雨",
            "85":"にわか雪","86":"にわか雪",
            "95":"雷雨","96":"雷雨","99":"雷雨"
          }[tostring] // "—";

          . as $r
          | {
              now: {
                temp: ($r.current.temperature_2m | round),
                cond: ($r.current.weather_code | jp)
              },
              days: [
                range(0; ($r.daily.time | length)) as $i | {
                  date: $r.daily.time[$i],
                  hi: ($r.daily.temperature_2m_max[$i] | round),
                  lo: ($r.daily.temperature_2m_min[$i] | round),
                  rain: ($r.daily.precipitation_probability_max[$i] // 0),
                  mm: (($r.daily.precipitation_sum[$i] // 0) * 10 | round / 10),

                  parts: [
                    range(0; 4) as $b
                    | [range(0; 6) | $r.hourly.precipitation_probability[$i * 24 + $b * 6 + .] // 0]
                    | max
                  ],

                  tparts: [
                    range(0; 4) as $b
                    | [range(0; 6) | $r.hourly.temperature_2m[$i * 24 + $b * 6 + .]]
                    | map(select(. != null))
                    | if length == 0 then null
                      else {lo: (min | round), hi: (max | round)} end
                  ],

                  hours: {
                    t: [range(0; 24) | $r.hourly.temperature_2m[$i * 24 + .]],
                    p: [range(0; 24) | $r.hourly.precipitation_probability[$i * 24 + .] // 0]
                  }
                }
              ],
              ts: (now | floor)
            }' > "$tmp"

    ${pkgs.coreutils}/bin/mv "$tmp" ${cache}
    trap - EXIT
  '';
in {
  systemd.user.services.weather = {
    Unit.Description = "fetch the forecast";
    Service = {
      Type = "oneshot";
      ExecStart = "${fetch}";
    };
  };

  systemd.user.timers.weather = {
    Unit.Description = "refresh the forecast";
    Timer = {
      OnStartupSec = "20s";
      OnUnitActiveSec = "15m";
    };
    Install.WantedBy = ["timers.target"];
  };
}
