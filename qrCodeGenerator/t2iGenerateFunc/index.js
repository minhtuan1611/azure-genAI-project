const axios = require('axios')
const { BlobServiceClient } = require('@azure/storage-blob')

module.exports = async function (context, req) {
  context.log('Processing Azure HTTP Trigger function')

  // Define the OpenAI API endpoint for DALL-E 3
  const openAiUrl =
    'https://swedencentral.api.cognitive.microsoft.com/openai/deployments/dall-e-3/images/generations?api-version=2024-02-01'

  // Retrieve API key from environment variables (set in Azure Function App settings)
  const apiKey = process.env.OPENAI_API_KEY
  if (!apiKey) {
    context.res = {
      status: 500,
      body: 'Missing API Key. Set OPENAI_API_KEY in environment variables.',
    }
    return
  }

  // Get user prompt from request body
  const userPrompt = req.body?.prompt
  if (!userPrompt) {
    context.res = {
      status: 400,
      body: 'Please provide a prompt in the request body.',
    }
    return
  }

  // Define request body for DALL-E 3
  const requestBody = {
    prompt: userPrompt,
    n: 1,
    size: '1024x1024',
  }

  try {
    // Make the HTTP POST request to OpenAI to generate an image
    const response = await axios.post(openAiUrl, requestBody, {
      headers: {
        'Content-Type': 'application/json',
        'api-key': apiKey,
      },
    })

    // Extract the image URL from the response
    const imageUrl = response.data.data[0].url

    // Download the image using the URL
    const imageResponse = await axios.get(imageUrl, {
      responseType: 'arraybuffer',
    })
    const imageBuffer = Buffer.from(imageResponse.data)

    // Get Blob Storage details
    const connectionString = process.env.STORAGE_CONNECTION_STRING
    const containerName = 't2i-generated-images'
    const blobServiceClient =
      BlobServiceClient.fromConnectionString(connectionString)
    const containerClient = blobServiceClient.getContainerClient(containerName)

    // Create the container if it does not exist
    await containerClient.createIfNotExists({ access: 'blob' })

    // Generate a unique blob name (e.g., based on user prompt or a timestamp)
    const blobName = `image-${Date.now()}.png`
    const blockBlobClient = containerClient.getBlockBlobClient(blobName)

    // Upload the image to Blob Storage
    await blockBlobClient.upload(imageBuffer, imageBuffer.length)

    // Return the image URL from Blob Storage
    context.res = {
      status: 200,
      body: {
        message: 'Image successfully generated and uploaded to Blob Storage.',
        imageUrl: blockBlobClient.url,
      },
      headers: {
        'Content-Type': 'application/json',
      },
    }
  } catch (error) {
    context.log.error('Error calling OpenAI API:', error.message)

    context.res = {
      status: error.response?.status || 500,
      body: {
        error: error.message,
        details: error.response?.data || 'No additional error details.',
      },
    }
  }
}
