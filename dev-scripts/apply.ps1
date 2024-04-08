function Convert-To-UnixPath {
  param (
    [string]$Path
  )

  return $Path -replace '\\', '/'

}

function Apply-Config {
  param (
      [string]$dir,
      [System.IO.FileInfo]$config
  )

  # Pull the name of the service/deployment from the config
  $objName = & Out-String -InputObject "(./$dir/$($config.Name)).metadata.name" | dhall

  # objName will be 'Some "example"'
  # so we need to pull out the name
  if ($objName -match '\"(.*)\"') {
    $objName = $matches[1]
    Write-Host "$objName"
    kubectl delete $config.BaseName $objName
    kubectl apply -f "$dir/$($config.BaseName).yaml"
  } else {
    Write-Host "No object name provided"
  }
}

Get-ChildItem -Directory -Path kubernetes | ForEach-Object {
  $dir = "kubernetes/$($_.Name)"
  Get-ChildItem -Path $dir -Filter *.dhall | ForEach-Object {
    Write-Host "compiling $($_.FullName)"
    Write-Host "> resolving..."
    $resolved = dhall resolve --file "$($_.FullName)"
    Write-Host "> normalizing..."
    $normalized = Out-String -InputObject $resolved | dhall normalize
    Write-Host "> converting to yaml..."
    Out-String -InputObject $normalized | dhall-to-yaml | Out-File -FilePath "$dir/$($_.BaseName).yaml"
    Write-Host "> done"
    Apply-Config -dir $dir -config $_
  }
}
