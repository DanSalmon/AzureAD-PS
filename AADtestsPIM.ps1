##creates a group, assigns it to a , creates a user, assigns it to the group
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

##creates new group
$group = New-MgGroup -DisplayName "Test_roleassigned" -Description "A test group to add Azure AD admin roles to" -MailEnabled:$false -SecurityEnabled -Mail-enabled:$false -IsAssignableToRole:$true

##finds the ID of the PowerPlatform Administrator admin role
$roleDefinition = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'PowerPlatform Administrator'"

##sets passwords for users
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "TestPass"

##adds a new user called newtest
$NewUser = New-AzureADUser -AccountEnabled $True -DisplayName "newtest" -PasswordProfile $PasswordProfile

##adds the new user to the group
Add-AzureADGroupMember -ObjectId $group.Id -RefObjectId $NewUser.Id

##initialises an array for the command then adds a group to an eligible PIM role
$params = @{
    "PrincipalId" = $group.Id
    "RoleDefinitionId" = $roleDefinition.Id
    "Justification" = "Add eligible assignment"
    "DirectoryScopeId" = "/"
    "Action" = "AdminAssign"
    "ScheduleInfo" = @{
      "StartDateTime" = Get-Date
      "Expiration" = @{
        "Type" = "AfterDuration"
        "Duration" = "PT10H"
        }
      }
     }
  
  New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params | 
    Format-List Id, Status, Action, AppScopeId, DirectoryScopeId, RoleDefinitionId, IsValidationOnly, Justification, PrincipalId, CompletedDateTime, CreatedDateTime