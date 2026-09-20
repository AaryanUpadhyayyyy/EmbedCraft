const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { CloudFrontClient, CreateInvalidationCommand } = require("@aws-sdk/client-cloudfront");
const fs = require("fs");
const path = require("path");

// Simple extension to MIME-type mapping
const MIME_TYPES = {
  ".html": "text/html",
  ".css": "text/css",
  ".js": "application/javascript",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".avif": "image/avif",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".json": "application/json",
};

function getContentType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  return MIME_TYPES[ext] || "application/octet-stream";
}

async function uploadDir(s3Client, bucketName, distPath) {
  async function walk(dir) {
    const files = await fs.promises.readdir(dir);
    for (const file of files) {
      const fullPath = path.join(dir, file);
      const stat = await fs.promises.stat(fullPath);
      if (stat.isDirectory()) {
        await walk(fullPath);
      } else {
        const relativePath = path.relative(distPath, fullPath).replace(/\\/g, "/");
        const fileContent = await fs.promises.readFile(fullPath);
        const contentType = getContentType(fullPath);
        
        console.log(`Uploading ${relativePath} (${contentType})...`);
        const putParams = {
          Bucket: bucketName,
          Key: relativePath,
          Body: fileContent,
          ContentType: contentType,
        };

        // Prevent caching for HTML files so browsers always fetch the fresh version
        if (contentType === "text/html") {
          putParams.CacheControl = "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0";
        }

        await s3Client.send(new PutObjectCommand(putParams));
      }
    }
  }
  await walk(distPath);
}

async function run() {
  const args = process.argv.slice(2);
  if (args.length < 3) {
    console.error("Usage: node deploy_static.js <distPath> <bucketName> <distributionId>");
    process.exit(1);
  }

  const [distPath, bucketName, distributionId] = args;
  
  if (!fs.existsSync(distPath)) {
    console.error(`Error: Directory ${distPath} does not exist.`);
    process.exit(1);
  }

  console.log(`Deploying ${distPath} to bucket ${bucketName}...`);
  
  const s3 = new S3Client({ region: "ap-south-1" });
  await uploadDir(s3, bucketName, distPath);
  console.log("S3 upload completed successfully!");

  console.log(`Creating CloudFront invalidation for ${distributionId}...`);
  const cf = new CloudFrontClient({ region: "us-east-1" });
  const invRes = await cf.send(
    new CreateInvalidationCommand({
      DistributionId: distributionId,
      InvalidationBatch: {
        CallerReference: `deploy-${Date.now()}`,
        Paths: {
          Quantity: 1,
          Items: ["/*"],
        },
      },
    })
  );
  console.log(`Invalidation created successfully! Invalidation ID: ${invRes.Invalidation.Id}`);
}

run().catch((err) => {
  console.error("Deployment failed:", err);
  process.exit(1);
});
