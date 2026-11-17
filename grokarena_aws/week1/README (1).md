# IAM + S3 Assignment

Region used: Mumbai (`ap-south-1`). All steps are done in the AWS Console.

---

## Part 1: IAM user, group and S3 read-only policy

### 1. Create the policy
1. Go to **IAM -> Policies -> Create policy**.
2. Open the **JSON** tab and paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:Get*", "s3:List*"],
      "Resource": "*"
    }
  ]
}
```

3. Click **Next**, name it `S3ReadOnlyOnly`, then **Create policy**.

### 2. Create the group and attach the policy
1. Go to **IAM -> User groups -> Create group**.
2. Group name: `s3-readers`.
3. Select the `S3ReadOnlyOnly` policy.
4. Click **Create user group**.

### 3. Create the user and add it to the group
1. Go to **IAM -> Users -> Create user**.
2. User name: `s3-read-user`.
3. Click **Next**, select the group `s3-readers`.
4. Click **Next -> Create user**.

---

## Part 2: S3 bucket with versioning and access policy

### 1. Create the bucket
1. Go to **S3 -> Create bucket**.
2. Bucket name: `s3-assignment-<your-name>` (must be unique and lowercase).
3. Keep **Block all public access** ticked.
4. Click **Create bucket**.

### 2. Enable versioning
1. Open the bucket -> **Properties** tab.
2. **Bucket Versioning** -> **Edit** -> **Enable** -> **Save changes**.
![alt text](<Screenshot 2026-11-17 151329.png>)

### 3. Set the access policy
1. Open the bucket -> **Permissions** tab -> **Bucket policy** -> **Edit**.
2. Paste the policy below. Replace `<ACCOUNT_ID>` with your 12-digit account ID and `<bucket-name>` with your bucket name:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowUserToReadObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ID>:user/s3-read-user"
      },
      "Action": ["s3:GetObject", "s3:GetObjectVersion"],
      "Resource": "arn:aws:s3:::<bucket-name>/*"
    },
    {
      "Sid": "AllowUserToListBucket",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ID>:user/s3-read-user"
      },
      "Action": ["s3:ListBucket", "s3:ListBucketVersions"],
      "Resource": "arn:aws:s3:::<bucket-name>"
    }
  ]
}
```

3. Click **Save changes**.
