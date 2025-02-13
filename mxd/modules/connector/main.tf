#
#  Copyright (c) 2023 Contributors to the Eclipse Foundation
#
#  See the NOTICE file(s) distributed with this work for additional
#  information regarding copyright ownership.
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License, Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.
#
#  SPDX-License-Identifier: Apache-2.0
#

module "minio" {
  source            = "../minio"
  humanReadableName = lower(var.humanReadableName)
  minio-username    = var.minio-config.minio-username
  minio-password    = var.minio-config.minio-password
}

resource "helm_release" "connector" {
  name              = lower(var.humanReadableName)
  force_update      = true
  dependency_update = true
  reuse_values      = true
  cleanup_on_fail   = true
  replace           = true

  repository = "https://eclipse-tractusx.github.io/charts/dev"
  chart      = "tractusx-connector"

  values = [
    file("${path.module}/values.yaml"),
    # dynamically set the vault secrets
    yamlencode({
      "vault" : {
        "server" : {
          "postStart" : [
            "sh",
            "-c",
            join(" && ", [
              "sleep 5",
              "/bin/vault kv put secret/client-secret content=${local.client_secret}",
              "/bin/vault kv put secret/aes-keys content=${local.aes_key_b64}",
              "/bin/vault kv put secret/${var.ssi-config.oauth-secretalias} content=${var.ssi-config.oauth-clientsecret}",
              "/bin/vault kv put secret/edc.aws.access.key content=${var.minio-config.minio-username}",
              "/bin/vault kv put secret/edc.aws.secret.access.key content=${var.minio-config.minio-password}",
              "/bin/vault kv put secret/${var.azure-account-name}-key content=${var.azure-account-key}",
              "/bin/vault kv put secret/${var.azure-account-name}-sas content='${local.azure-sas-token}'",
            ])
          ]
        }
      }
    }),
    yamlencode({
      controlplane : {
        env : {
          "TX_SSI_ENDPOINT_AUDIENCE" : "http://${kubernetes_service.controlplane-service.metadata.0.name}:8084/api/v1/dsp"
          "EDC_DSP_CALLBACK_ADDRESS" : "http://${kubernetes_service.controlplane-service.metadata.0.name}:8084/api/v1/dsp"
          "EDC_HOSTNAME" : "${var.humanReadableName}-tractusx-connector-controlplane"
          "EDC_BLOBSTORE_ENDPOINT_TEMPLATE" : local.edc-blobstore-endpoint-template
          "EDC_DATAPLANE_SELECTOR_DEFAULTPLANE_SOURCETYPES" : "HttpData,AmazonS3,AzureStorage"
          "EDC_DATAPLANE_SELECTOR_DEFAULTPLANE_DESTINATIONTYPES" : "HttpProxy,AmazonS3,AzureStorage"
        }
        ssi : {
          miw : {
            url : var.ssi-config.miw-url
            authorityId : var.ssi-config.miw-authorityId
          }
          oauth : {
            tokenurl : var.ssi-config.oauth-tokenUrl
            client : {
              id : var.ssi-config.oauth-clientid
              secretAlias : var.ssi-config.oauth-secretalias
            }
          }
        }
      }
      dataplane : {
        env : {
          "EDC_BLOBSTORE_ENDPOINT_TEMPLATE" : local.edc-blobstore-endpoint-template
        }
        aws : {
          endpointOverride : "http://${local.minio-url}"
        }
        url : {
          public : "http://localhost/${var.humanReadableName}/api/public"
        }
      }
    })
  ]
  set {
    name  = "participant.id"
    value = var.participantId
  }

  set {
    name  = "controlplane.image.pullPolicy"
    value = var.image-pull-policy
  }

  set {
    name  = "dataplane.image.pullPolicy"
    value = var.image-pull-policy
  }

  set {
    name  = "postgresql.jdbcUrl"
    value = local.jdbcUrl
  }

  set {
    name  = "postgresql.auth.username"
    value = var.database-credentials.user
  }

  set {
    name  = "postgresql.auth.password"
    value = var.database-credentials.password
  }
  // we'll use a central postgres
  set {
    name  = "install.postgresql"
    value = "false"
  }

}

resource "random_string" "kc_client_secret" {
  length = 16
}

resource "random_string" "aes_key_raw" {
  length = 16
}

locals {
  aes_key_b64                     = base64encode(random_string.aes_key_raw.result)
  client_secret                   = base64encode(random_string.kc_client_secret.result)
  jdbcUrl                         = "jdbc:postgresql://${var.database-host}:${var.database-port}/${var.database-name}"
  edc-blobstore-endpoint-template = "${var.azure-url}/%s"
  azure-sas-token                 = jsonencode({ edctype = "dataspaceconnector:azuretoken", sas = var.azure-account-key-sas })
  minio-url                       = module.minio.minio-url
}
