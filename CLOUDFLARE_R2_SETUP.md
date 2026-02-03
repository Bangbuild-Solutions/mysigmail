# Cloudflare R2 Setup Guide for MySigMail

## Step 1: Create R2 Bucket

1. Go to Cloudflare Dashboard → R2 Object Storage
2. Click "Create bucket"
3. Name it (e.g., `mysigmail-images`)
4. Click "Create bucket"

## Step 2: Enable Public Access

1. Open your bucket
2. Go to "Settings" tab
3. Under "Public access", click "Allow Access"
4. Copy the public bucket URL (e.g., `https://pub-xxxxx.r2.dev`)
5. (Optional) Set up a custom domain for better branding

## Step 3: Create API Token

1. Go to R2 → "Manage R2 API Tokens"
2. Click "Create API token"
3. Configure:
   - **Token name**: `mysigmail-upload`
   - **Permissions**: Object Read & Write
   - **Specify bucket**: Select your bucket (recommended for security)
   - **TTL**: Never expire (or set expiration as needed)
4. Click "Create API Token"
5. **IMPORTANT**: Copy the Access Key ID and Secret Access Key immediately (you won't see them again!)

## Step 4: Get Your Account ID

1. In Cloudflare Dashboard, look at the URL or sidebar
2. Your Account ID is visible in the R2 section
3. Or find it in Account → Account ID

## Step 5: Configure Dokploy Environment Variables

In Dokploy's Environment tab, add these variables:

```bash
VITE_AWS_S3_ENDPOINT=https://YOUR-ACCOUNT-ID.r2.cloudflarestorage.com
VITE_AWS_S3_URL=https://pub-xxxxxxxxxxxxx.r2.dev
VITE_AWS_S3_BASKET=mysigmail-images
VITE_AWS_S3_ID=your_access_key_id_from_step3
VITE_AWS_S3_KEY=your_secret_access_key_from_step3
VITE_AWS_S3_REGION=auto
```

### Finding Your Values:

- **VITE_AWS_S3_ENDPOINT**: `https://<ACCOUNT-ID>.r2.cloudflarestorage.com`
  - Replace `<ACCOUNT-ID>` with your Cloudflare Account ID
  
- **VITE_AWS_S3_URL**: Your public bucket URL from Step 2
  - Example: `https://pub-abc123def456.r2.dev`
  - Or your custom domain if configured
  
- **VITE_AWS_S3_BASKET**: Your bucket name from Step 1
  
- **VITE_AWS_S3_ID**: Access Key ID from Step 3
  
- **VITE_AWS_S3_KEY**: Secret Access Key from Step 3
  
- **VITE_AWS_S3_REGION**: Always use `auto` for R2

## Step 6: CORS Configuration (Important!)

To allow uploads from your domain, configure CORS:

1. Go to your R2 bucket → Settings → CORS policy
2. Add this configuration:

```json
[
  {
    "AllowedOrigins": [
      "https://your-mysigmail-domain.com",
      "http://localhost:5173"
    ],
    "AllowedMethods": [
      "GET",
      "PUT",
      "POST",
      "DELETE"
    ],
    "AllowedHeaders": [
      "*"
    ],
    "ExposeHeaders": [
      "ETag"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

Replace `your-mysigmail-domain.com` with your actual Tailscale domain or custom domain.

## Step 7: Test Upload

1. Deploy your app in Dokploy
2. Open MySigMail
3. Try uploading an avatar or logo
4. Check your R2 bucket to confirm the file was uploaded

## Troubleshooting

### Upload fails with "Access Denied"
- Check API token permissions (needs Object Read & Write)
- Verify the bucket name matches exactly
- Ensure API token is scoped to the correct bucket

### Upload fails with CORS error
- Add your domain to CORS AllowedOrigins
- Include both HTTP and HTTPS if testing locally
- Wait a few minutes for CORS changes to propagate

### Images don't display
- Verify public access is enabled on the bucket
- Check the VITE_AWS_S3_URL matches your public bucket URL
- Test the public URL directly in a browser

## Cost Estimation

Cloudflare R2 pricing (as of 2024):
- **Storage**: $0.015/GB/month
- **Class A operations** (writes): $4.50 per million
- **Class B operations** (reads): $0.36 per million
- **Egress**: FREE (no bandwidth charges!)

For internal use with ~100 signatures and images:
- Storage: ~1GB = $0.015/month
- Operations: Negligible
- **Total: < $1/month** 🎉

## Security Best Practices

1. ✅ Use API tokens scoped to specific buckets only
2. ✅ Set token expiration if possible
3. ✅ Never commit credentials to git
4. ✅ Use Tailscale to restrict access to internal network
5. ✅ Regularly rotate API tokens
6. ✅ Monitor R2 usage in Cloudflare dashboard

## Optional: Custom Domain

Instead of `pub-xxxxx.r2.dev`, use your own domain:

1. Go to bucket → Settings → Custom Domains
2. Click "Connect Domain"
3. Enter your domain (e.g., `cdn.yourdomain.com`)
4. Add the CNAME record to your DNS
5. Update `VITE_AWS_S3_URL` to use your custom domain

Benefits:
- Professional appearance
- Better branding
- Consistent with your domain
