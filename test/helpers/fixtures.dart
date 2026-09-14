/// Shared fixtures, so a change to a wire shape lands in one place rather than
/// in every test that happens to build one.
///
/// Empty since `_template` was removed: every fixture in here described that
/// slice. Kept as the agreed home for the next one rather than deleted and
/// rediscovered later. Add fixtures in pairs — the model as the server sends
/// it, and the entity it maps to — plus a sparse variant for the fields a real
/// API omits.
abstract final class Fixtures {}
