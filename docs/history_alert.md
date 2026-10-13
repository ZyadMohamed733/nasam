# Alert History

NASAM-621. The list and details read the real API through
`HistoryAlertRemoteDataSource` (`lib/features/history_alert/data/datasources/`),
on the authenticated Dio client. The fixture data source and its device
scenarios are gone; the backend's own dummy data stands in until the Alert
Engine persists fired alerts.

## Endpoints

From the backend's API contract (`API-CONTRACT.md`, shared with the team):

| App call | Endpoint |
| --- | --- |
| List, a page at a time | `GET /alerts/history?page=&limit=20&alertType=&from=&to=&search=` |
| Details | `GET /alerts/history/:historyId` |

- **Level 2 only.** The app never sends `accountId`; the API scopes to the
  user's company and answers 404 for another company's alert.
- **Filter.** The sheet's type chips send `alertType` (`SPEED`, `SENSOR`,
  `DOWNTIME`). Geofence is hidden until it ships (TODO in
  `AlertHistoryFilterSheet.types`). Date presets and the custom range are sent
  as UTC instants in `from` and `to`, with day boundaries on the Saudi
  calendar (`AlertHistoryFilter.saudiUtcOffset`) until the API gives the
  company time zone.
- **Search.** The search box sends `search`, which the API matches across
  vehicle name and code, alert name and sensor name. That is how the user
  narrows to a vehicle, an alert name or a sensor — there are no pickers.
- **Paging.** Infinite scroll: the next page loads near the end of the list;
  pull to refresh reloads page one.
- **Language.** Names arrive in both languages and are picked on screen; the
  `x-lang` header only affects error messages.

## Known gaps

- **Location** is coordinates only; the API sends no address.
- **Sensor type** is shown from its code (`TEMPERATURE` reads
  "Temperature"); the API has no translations for it.
- **Dev data.** The backend's dummy vehicle and sensor ids do not exist in
  `/assets` or `/sensors`, so searching for a real vehicle in dev returns
  nothing until the real data source lands.
- **Permission.** The API uses the Alert Management view permission until
  Alert History has its own; without it the list shows the 403 error state.
