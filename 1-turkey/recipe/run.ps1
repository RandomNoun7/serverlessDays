using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$weight = $Request.Query.weight

if (-not $weight) {
    Push-OutputBinding -Name Response -value ([HttpResponseContext]@{
            StatusCode = [System.Net.HttpStatusCode]::BadRequest
            Body       = "No Weight Given For Turkey"
        })
    Write-Error "No Weight Given"
    return
}

$ingredients = @(
    @{
        name       = 'salt'
        measure    = 'cups'
        multiplier = 0.05
    },
    @{
        name       = 'water'
        measure    = 'gallons'
        multiplier = 0.66
    },
    @{
        name       = 'Brown Sugar'
        measure    = 'cups'
        multiplier = 0.05
    },
    @{
        name       = 'Shallots'
        measure    = 'lbs'
        multiplier = 0.2
    },
    @{
        name       = 'Cloves of garlic'
        measure    = 'lbs'
        multiplier = 0.4
    },
    @{
        name       = 'Whole peppercorns'
        measure    = 'tablespoons'
        multiplier = 0.13
    },
    @{
        name       = 'Dried juniper berries'
        measure    = 'tablespoons'
        multiplier = 0.13
    },
    @{
        name       = 'Fresh rosemary'
        measure    = 'tablespoons'
        multiplier = 0.13
    },
    @{
        name       = 'Thyme'
        measure    = 'tablespoons'
        multiplier = 0.06
    },
    @{
        name       = 'Brine time'
        measure    = 'hours'
        multiplier = 2.4
    },
    @{
        name       = 'Roast time'
        measure    = 'minutes'
        multiplier = 15.0
    }
)

$properties = @(
    'name',
    'measure',
    @{
        Name = 'value'
        Expression = {[Math]::Round(($_.multiplier * $weight),2)}
    }
)

$ingredientsOuput = $ingredients | Select-Object $properties

#   Brine time (in hours) = 2.4 * lbs of turkey
#   Roast time (in minutes) = 15 * lbs of turkey
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = (ConvertTo-JSON $ingredientsOuput)
    })
