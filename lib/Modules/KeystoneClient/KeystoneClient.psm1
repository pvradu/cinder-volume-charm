function Get-RequestHeaders {
    return @{
        'Accept' = 'application/json'
        'Content-Type' = 'application/json'
    }
}

function Get-KeystoneTokenRequestBody {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$APIVersion,
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$UserPassword
    )
    switch($APIVersion) {
        "2" {
            return @{
                'auth' = @{
                    'passwordCredentials' = @{
                        'password' = $UserPassword
                        'username' = $UserName
                    }
                    'tenantName' = $ProjectName
                }
            }
        }
        "3" {
            return @{
                "auth" = @{
                    "identity" = @{
                        "methods" = @("password")
                        "password" = @{
                            "user" = @{
                                "name" = $UserName
                                "password" = $UserPassword
                                "domain" = @{
                                    "name" = "default"
                                }
                            }
                        }
                    }
                }
            }
        }
        default {
            Throw "Keystone API version $APIVersion is not supported at the moment"
        }
    }
}

function Get-KeystoneTokenID {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AuthURL,
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$UserPassword
    )
    $tokenResponse = $global:TOKEN_RESPONSE
    if($tokenResponse) {
        $token = ConvertFrom-Json $tokenResponse.Content
        $currentDate = Get-Date
        $tokenExpiringDate = [datetime]$token.expires_at
        $isExpired = $currentDate -gt $tokenExpiringDate
        if(!$isExpired) {
            return $tokenResponse.Headers['X-Subject-Token']
        }
    }
    $headers = Get-RequestHeaders
    $body = Get-KeystoneTokenRequestBody -APIVersion "3" -ProjectName $ProjectName `
                                         -UserName $UserName -UserPassword $UserPassword
    $response = Invoke-WebRequest -Uri "${AuthURL}/v3/auth/tokens" -Method Post -Headers $headers `
                                  -Body (ConvertTo-Json -InputObject $body -Depth 10) -UseBasicParsing
    $global:TOKEN_RESPONSE = $response
    return $global:TOKEN_RESPONSE.Headers['X-Subject-Token']
}

function Get-KeystoneIdentityIDs {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AuthURL,
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$UserPassword
    )
    $tokenID = Get-KeystoneTokenID -AuthURL $AuthURL -ProjectName $ProjectName `
                                   -UserName $UserName -UserPassword $UserPassword
    $tokenObj = (ConvertFrom-Json $global:TOKEN_RESPONSE.Content).Token
    return @{
        'user_id' = $tokenObj.user.id
        'project_id' = $tokenObj.project.id
    }
}
