/// `user.type` from the API's login / verify-otp / refresh responses.
///
/// Display/labelling only. `permissions` on [UserType]'s owner
/// (`UserEntity.permissions`) is the actual authorization signal -- nothing
/// should branch on this value to decide what a user is allowed to do.
enum UserType { admin, employee, clientAdmin, clientEmployee }
