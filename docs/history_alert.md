# Alert history device scenarios

Change `FakeHistoryDatasource.deviceTestScenario` in
`lib/features/history_alert/data/datasources/fake_history_datasource.dart`, then
restart a debug build to select a fixture response.

`HistoryAlertFixtureScenarios` in the same data-source folder contains the
static scenario constants.

- `success`: list and selected alert details load from the fixture.
- `empty`: the history list returns no alerts.
- `serverError`, `networkError`, `timeout`, `unauthorized`, `rateLimit`,
  `malformedPayload`, `unknownError`: exercise the corresponding list error UI.
- `serverErrorOnce`: fail the first list request, then return the fixture on
  retry.
- `detailsServerError`, `detailsNetworkError`, `detailsTimeout`,
  `detailsUnauthorized`, `detailsRateLimit`, `detailsMalformedPayload`,
  `detailsUnknownError`: keep the list successful, then exercise the detail
  error UI after opening an alert.
- `detailsServerErrorOnce`: fail the first detail request, then return the
  fixture on retry.

These scenarios are active in debug builds; release builds use `success`.
