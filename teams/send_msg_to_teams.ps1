[String]$var = "This is a sample content"
$JSONBody = [PSCustomObject][Ordered]@{
    "@type"      = "MessageCard"
    "@context"   = "http://schema.org/extensions"
    "summary"    = "My first alert summary!"
    "themeColor" = '0078D7'
    "title"      = "My first alert."
    "text"       = "Add detailed description of the alert here!
                         You can also use variables: $var"
}
$TeamMessageBody = ConvertTo-Json $JSONBody -Depth 100
 
$parameters = @{
    "URI"         = ''
    "Method"      = 'POST'
    "Body"        = $TeamMessageBody
    "ContentType" = 'application/json'
}
Invoke-RestMethod @parameters