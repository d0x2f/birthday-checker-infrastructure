#!/bin/bash

set -o errexit

# Verify environment
SCOPE_ID=$1
if [ -z "$SCOPE_ID" ]; then
  echo "Please pass a unique scope ID as an argument."
  exit 1
fi

if [ -z "$BILLING_ACCOUNT_ID" ]; then
  echo "Please set BILLING_ACCOUNT_ID to the id of the billing account you wish to use."
  exit 1
fi

account=$(gcloud config list account --format "value(core.account)")
if [ -z "$account" ]; then
  echo "Please authenticate the gcloud client before running this script."
fi

echo "Using scope ID: ${SCOPE_ID}"
TF_PROJECT_ID="bc-tf-${SCOPE_ID}"
PROJECT_ID="bc-app-${SCOPE_ID}"

echo -e "\n=> Creating terraform state project..."
if gcloud projects describe "$TF_PROJECT_ID" > /dev/null 2>&1; then
  echo -e "==> Project already exists."
else
  gcloud projects create "$TF_PROJECT_ID" --name="Birthday Checker Terraform"
fi

gcloud config set project "$TF_PROJECT_ID"

echo -e "\n=> Enabling APIs..."
gcloud services enable \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  cloudbilling.googleapis.com \
  cloudresourcemanager.googleapis.com \
  appengine.googleapis.com

echo -e "\n=> Linking billing account to terraform project..."
gcloud beta billing projects link "$TF_PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

echo -e "\n=> Creating terraform service account..."
if gcloud iam service-accounts describe "terraform@${TF_PROJECT_ID}.iam.gserviceaccount.com" > /dev/null 2>&1; then
  echo "==> Service account already exists."
else
  gcloud iam service-accounts create "terraform"
fi

echo -e "\n=> Creating terraform backend bucket..."
if gcloud storage buckets describe "gs://${TF_PROJECT_ID}" > /dev/null 2>&1; then
  echo "==> Terraform backend bucket already exists."
else
  gcloud storage buckets create "gs://${TF_PROJECT_ID}"
fi

echo -e "\n=> Creating application project..."
if gcloud projects describe "$PROJECT_ID" > /dev/null 2>&1; then
  echo -e "==> Project already exists."
else
  gcloud projects create "$PROJECT_ID" --name="Birthday Checker App"
fi

echo -e "\n=> Linking billing account to application project..."
gcloud beta billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

echo -e "\n=> Granting Permissions..."
# For access to the state bucket
gcloud storage buckets add-iam-policy-binding "gs://$TF_PROJECT_ID" \
  --member="serviceAccount:terraform@${TF_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"

# Permission over the application project
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:terraform@$TF_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/owner"

# Permission to manage cloud run resources
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:terraform@$TF_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Permission to manage service accounts
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:terraform@$TF_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

echo -e "\n=> Done!"

export PROJECT_ID
export TF_PROJECT_ID
export TF_VAR_project_id=$PROJECT_ID
