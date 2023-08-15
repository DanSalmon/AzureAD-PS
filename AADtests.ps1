##creates a group, assigns it an admin role, creates a user, assigns it to the group
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

##creates new group
$group = New-MgGroup -DisplayName "Test_roleassigned" -Description "A test group to add Azure AD admin roles to" -MailEnabled:$false -SecurityEnabled -Mail-enabled:$false -IsAssignableToRole:$true

##finds the ID of the PowerPlatform Administrator admin role
$roleDefinition = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'PowerPlatform Administrator'"

##assigns the PowerPlatform Administrator role to the new group
New-MgRoleManagementDirectoryRoleAssignment -DirectoryScopeId '/' -RoleDefinitionId $roleDefinition.Id -PrincipalId $group.Id

##sets passwords for users
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "TestPass"

##adds a new user called newtest
$NewUser = New-AzureADUser -AccountEnabled $True -DisplayName "newtest" -PasswordProfile $PasswordProfile

##adds the new user to the group
Add-AzureADGroupMember -ObjectId $group.Id -RefObjectId $NewUser.Id