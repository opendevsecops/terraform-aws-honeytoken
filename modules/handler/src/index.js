const url = require('url')
const zlib = require('zlib')
const https = require('https')
const awsSdk = require('aws-sdk')

const s3 = new awsSdk.S3()
const ses = new awsSdk.SES()

const ipWhitelist = (process.env.IP_WHITELIST || '').split(',').map(v => v.trim()).filter(v => v)
const userAgentWhitelist = (process.env.USER_AGENT_WHITELIST || '').split('|').map(v => v.trim()).filter(v => v)

const send = async (from, to, subject, body) => {
    return ses.sendEmail({
        Source: from,

        Destination: {
            ToAddresses: [
                to
            ]
        },

        Message: {
            Subject: {
                Charset: 'UTF-8',
                Data: subject
            },

            Body: {
                Text: {
                    Charset: 'UTF-8',
                    Data: body
                }
            }
        }
    }).promise()
}

const post = async (uri, body) => {
    return new Promise((resolve, reject) => {
        body = JSON.stringify(body)

        const options = url.parse(uri)

        options.method = 'POST'

        options.headers = {
            'Content-Type': 'application/json',
            'Content-Length': body.length
        }

        const req = https.request(options, (res) => {
            if (res.statusCode === 200) {
                res.on('end', () => {
                    resolve()
                })
            } else {
                reject(new Error(`Unexpected status code: ${res.statusCode}`))
            }
        })

        req.on('error', (error) => {
            reject(error)
        })

        req.end(body)
    })
}

const raiseAlert = async (record, meta) => {
    console.log(record)

    const { sourceIPAddress='unknown', userAgent='unknown' } = record

    console.log(process.env.NOTIFICATION_MESSAGE)

    const blocks = []

    blocks.push(process.env.NOTIFICATION_MESSAGE)
    blocks.push(`Source IP Address: ${sourceIPAddress}`)
    blocks.push(`User Agent: ${userAgent}`)

    Object.entries(meta || {}).forEach(([name, value]) => {
        blocks.push(`${name}: ${value}`)
    })

    const text = blocks.join('\n')

    console.log(text)

    if (process.env.SLACK_NOTIFICATION_URL) {
        await post(process.env.SLACK_NOTIFICATION_URL, {text})
    }
}

const detectThreat = async (record, meta) => {
    const { userIdentity, requestParameters, sourceIPAddress='unknown', userAgent='unknown' } = record || {}
    const { userName: u1='' } = userIdentity || {}
    const { userName: u2='' } = requestParameters || {}

    if ([u1, u2].includes(process.env.HONEYUSERNAME)) {
        if (ipWhitelist.includes(sourceIPAddress) || userAgentWhitelist.includes(userAgent)) {
            console.log(`Ignoring`)
            console.log(`Source IP Address: ${sourceIPAddress}`)
            console.log(`User Agent: ${userAgent}`)
        } else {
            await raiseAlert(record, {'User Name': process.env.HONEYUSERNAME, ...meta})
        }
    }
}

const fetchRecords = async (Bucket, Key) => {
    const { Body } = await s3.getObject({Bucket, Key}).promise()

    const data = zlib.gunzipSync(Body)

    const { Records } = JSON.parse(data)

    return Records || []
}

exports.handler = async (event) => {
    const { Records } = event

    await Promise.all((Records || []).map(async ({s3: _s3}) => {
        const { bucket: _bucket, object: _object } = _s3 || {}
        const { name } = _bucket || {}
        const { key } = _object || {}

        const meta = {
            'S3 Bucket': name,
            'S3 Key': key
        }

        const records = await fetchRecords(name, key)

        await Promise.all(records.map((record) => {
            return detectThreat(record, meta)
        }))
    }))
}
