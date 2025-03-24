const {
  BlobServiceClient,
  StorageSharedKeyCredential,
  generateBlobSASQueryParameters,
  BlobSASPermissions,
  SASProtocol,
} = require('@azure/storage-blob')

module.exports = async function (context, req) {
  const file = req.query.file
  const container = req.query.container || 'upload'

  if (!file) {
    context.res = { status: 400, body: "Missing 'file' parameter" }
    return
  }

  const accountName = process.env.Azure_Storage_AccountName
  const accountKey = process.env.Azure_Storage_AccountKey

  const credential = new StorageSharedKeyCredential(accountName, accountKey)

  const sasToken = generateBlobSASQueryParameters(
    {
      containerName: container,
      blobName: file,
      permissions: BlobSASPermissions.parse('cwr'),
      startsOn: new Date(),
      expiresOn: new Date(new Date().valueOf() + 15 * 60 * 1000), // 15 mins
      protocol: SASProtocol.Https,
    },
    credential
  ).toString()

  const sasUrl = `https://${accountName}.blob.core.windows.net/${container}/${file}?${sasToken}`

  context.res = {
    status: 200,
    body: { url: sasUrl },
  }
}
