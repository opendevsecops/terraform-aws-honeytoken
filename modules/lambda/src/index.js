const url = require('url');
const zlib = require('zlib');
const https = require('https');
const awsSdk = require('aws-sdk');

const s3 = new awsSdk.S3();
const ses = new awsSdk.SES();

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
    }).promise();
};

const post = async (uri, body) => {
    return new Promise((resolve, reject) => {
        body = JSON.stringify(body);

        const options = url.parse(uri);

        options.method = 'POST';

        options.headers = {
            'Content-Type': 'application/json',
            'Content-Length': body.length
        };

        const req = https.request(options, (res) => {
            if (res.statusCode === 200) {
                res.on('end', () => {
                    resolve();
                });
            } else {
                reject(new Error(`Unexpected status code: ${res.statusCode}`));
            }
        });

        req.on('error', (error) => {
            reject(error);
        });

        req.end(body);
    });
};

const raiseAlert = async (record) => {
	console.log('Malicious activity detected', record)

	const blocks = []

	blocks.push(`Malicious activity detected`)

	const text = blocks.join('\n')

	if (process.env.SLACK_NOTIFICATION_URL) {
		await post(process.env.SLACK_NOTIFICATION_URL, {text})
	}
};

const detectThreat = async (record) => {
	const { eventSource='', requestParameters } = record || {};
	const { userName='' } = requestParameters || {};

	if (eventSource === 'iam.amazonaws.com' && userName === process.env.HONEYUSERNAME) {
		await raiseAlert(record);
	}
};

const fetchRecords = async (Bucket, Key) => {
	const { Body } = await s3.getObject({Bucket, Key}).promise();

	const data = zlib.gunzipSync(Body);

	const { Records } = JSON.parse(data);

	return Records || [];
};

exports.handler = async (event) => {
	const { Records } = event;

	await Promise.all((Records || []).map(async ({s3: _s3}) => {
		const { bucket: _bucket, object: _object } = _s3 || {};
		const { name } = _bucket || {};
		const { key } = _object || {};

		const records = await fetchRecords(name, key);

		await Promise.all(records.map(detectThreat))
	}));
};
