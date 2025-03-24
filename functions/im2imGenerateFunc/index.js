const axios = require('axios')
const { BlobServiceClient } = require('@azure/storage-blob')

module.exports = async function (context, req) {
  context.log('Processing image-to-image (become-image) function')

  const { image, image_to_become, number_of_images } = req.body || {}

  if (!image || !image_to_become) {
    context.res = {
      status: 400,
      body: { error: "Missing 'image' or 'image_to_become' in request body." },
    }
    return
  }

  const replicateToken = process.env.REPLICATE_API_TOKEN
  const version =
    '8d0b076a2aff3904dfcec3253c778e0310a68f78483c4699c7fd800f3051d2b3'
  const apiUrl = 'https://api.replicate.com/v1/predictions'

  try {
    // 1. Call Replicate API using HTTP POST
    const replicateResponse = await axios.post(
      apiUrl,
      {
        version: version,
        input: {
          image,
          image_to_become,
          number_of_images: number_of_images || 1,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${replicateToken}`,
          'Content-Type': 'application/json',
          Prefer: 'wait',
        },
      }
    )

    const outputImages = replicateResponse.data.output
    if (!outputImages || outputImages.length === 0) {
      throw new Error('No output image returned from Replicate.')
    }

    // 2. Set up Blob Storage client
    const connectionString = process.env.STORAGE_CONNECTION_STRING
    const containerName = 'im2im-generated-images'
    const blobServiceClient =
      BlobServiceClient.fromConnectionString(connectionString)
    const containerClient = blobServiceClient.getContainerClient(containerName)

    await containerClient.createIfNotExists({ access: 'blob' })

    const resultUrls = []

    // 3. Download each output image and upload to Blob
    for (const imageUrl of outputImages) {
      const imageResponse = await axios.get(imageUrl, {
        responseType: 'arraybuffer',
      })
      const imageBuffer = Buffer.from(imageResponse.data)
      const blobName = `gen-im-${Date.now()}.png`
      const blockBlobClient = containerClient.getBlockBlobClient(blobName)
      await blockBlobClient.upload(imageBuffer, imageBuffer.length)
      resultUrls.push(blockBlobClient.url)
    }

    // 4. Return success
    context.res = {
      status: 200,
      body: {
        message:
          'Image(s) successfully generated and uploaded to Blob Storage.',
        imageUrls: resultUrls,
      },
      headers: {
        'Content-Type': 'application/json',
      },
    }
  } catch (error) {
    context.log.error('Error processing image:', error.message)
    context.res = {
      status: error.response?.status || 500,
      body: {
        error: error.message,
        details: error.response?.data || 'Unexpected error.',
      },
    }
  }
}
