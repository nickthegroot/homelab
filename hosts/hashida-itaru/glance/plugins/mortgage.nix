{
  title ? "30-Year Fixed Rate Mortgage Avg",
  cache ? "12h",
  seriesId ? "MORTGAGE30US",
}:
# Modified from https://github.com/glanceapp/community-widgets/blob/93d02606837b63d4963bbcb84a00492f03852bd5/widgets/st-louis-fed-us-mortgage-rates/README.md
{
  type = "custom-api";
  inherit title cache;
  url = "https://api.stlouisfed.org/fred/series/observations?series_id=${seriesId}&api_key=\${FRED_API_KEY}&file_type=json&sort_order=desc&limit=2";
  template = ''
    {{ $latest := .JSON.Float "observations.0.value" }}
    {{ $previous := .JSON.Float "observations.1.value" }}
    {{ $lastObserve := .JSON.String "observations.0.date" }}
    {{ $change := sub $latest $previous }}
    <div class="flex justify-between items-center gap-15">
      <div class="min-width-0">
        <a class="size-h3 block color-highlight" href="https://fred.stlouisfed.org/series/${seriesId}" target="_blank" rel="noreferrer">
          {{ .JSON.String "observations.0.value" }}%
        </a>
        <div class="text-truncate">St. Louis Federal Reserve</div>
      </div>
      <div class="shrink-0">
        <div class="size-h3 text-right {{ if lt $change 0.0 }}color-positive{{ else if gt $change 0.0 }}color-negative{{ end }}">
          {{ printf "%+.2f" $change }}%
        </div>
        <div class="text-right" title="Last change: {{ $lastObserve }}" {{ $lastObserve | parseRelativeTime "DateOnly" }}>
        </div>
      </div>
    </div>
  '';
}
