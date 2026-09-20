const { SQSClient, GetQueueAttributesCommand } = require('@aws-sdk/client-sqs');
require('dotenv').config();

async function checkQueue() {
    const queueUrl = process.env.AWS_SQS_QUEUE_URL;
    if (!queueUrl) {
        console.error('AWS_SQS_QUEUE_URL not set');
        return;
    }

    const client = new SQSClient({ region: process.env.AWS_REGION || 'us-east-1' });

    try {
        const command = new GetQueueAttributesCommand({
            QueueUrl: queueUrl,
            AttributeNames: [
                'ApproximateNumberOfMessages',
                'ApproximateNumberOfMessagesNotVisible',
                'ApproximateNumberOfMessagesDelayed'
            ]
        });

        const response = await client.send(command);
        console.log('--- SQS Queue Attributes ---');
        console.log(`Visible Messages: ${response.Attributes.ApproximateNumberOfMessages}`);
        console.log(`Invisible Messages: ${response.Attributes.ApproximateNumberOfMessagesNotVisible}`);
        console.log(`Delayed Messages: ${response.Attributes.ApproximateNumberOfMessagesDelayed}`);
        console.log('----------------------------');
    } catch (error) {
        console.error('Failed to get queue attributes:', error.message);
    }
}

checkQueue();
