
set args = Wscript.Arguments

downloadUrl = args.Item(0)
savePath = args.Item(1)

dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", downloadUrl, False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    .savetofile savePath, 2 '//overwrite
end with