```yaml
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSuperAdmin() {
      return request.auth != null && request.auth.token.role == 'super_admin';
    }

    function userAdminId() {
      return request.auth != null ? request.auth.token.adminId : null;
    }

    match /users/{userId} {
      allow read, write: if isSuperAdmin();
      allow read: if request.auth != null && userId == request.auth.uid;
    }

    match /vehicles/{vehicleId} {
      allow read: if isSuperAdmin() ||
                  userAdminId() == resource.data.adminId;

      allow create: if isSuperAdmin() ||
        (request.auth != null &&
         request.auth.token.role == 'admin' &&
         request.resource.data.adminId == request.auth.uid);

      allow update, delete: if isSuperAdmin() ||
        (request.auth != null &&
         request.auth.token.role == 'admin' &&
         resource.data.adminId == request.auth.uid);
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

> Ensure custom claims `role` and `adminId` are added to your Firebase Auth tokens (via Cloud Functions or the Admin SDK) so the rules can enforce fleet isolation.
