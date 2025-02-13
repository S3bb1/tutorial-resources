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

# configuration values for the MIW+Keycloak Postgres db
variable "keycloak-database" {
  default = "keycloak"
}
variable "keycloak-db-user" {
  default = "keycloak_user"
}
variable "miw-database" {
  default = "miw"
}
variable "miw-db-user" {
  default = "miw_user"
}
variable "postgres-port" {
  default = 5432
}

variable "keycloak-port" {
  default = 8080
}

variable "miw-api-port" {
  default = 8000
}

variable "miw-bpn" {
  default = "BPNL000000000000"
}

variable "alice-bpn" {
  default = "BPNL000000000001"
}

variable "bob-bpn" {
  default = "BPNL000000000002"
}

variable "trudy-bpn" {
  default = "BPNL000000000003"
}

variable "alice-azure-account-name" {
  default = "aliceazureaccount"
}

variable "alice-azure-account-key" {
  default = "aliceazurekey"
}

variable "alice-azure-key-sas" {
  default = "sv=2023-01-03&ss=btqf&srt=sco&st=2023-11-23T13%3A17%3A09Z&se=2030-01-01T00%3A00%3A00Z&sp=rwdxftlacup&sig=uvPcqmLj7%2FMuadAKXMCA7SvWCnClQ9EA1b15OB0m1bc%3D"
}

variable "bob-azure-account-name" {
  default = "bobazureaccount"
}

variable "bob-azure-account-key" {
  default = "bobazurekey"
}

variable "bob-azure-key-sas" {
  default = "sv=2023-01-03&ss=btqf&srt=sco&st=2023-11-23T13%3A18%3A49Z&se=2030-01-01T00%3A00%3A00Z&sp=rwdftlacup&sig=Xki%2B2nHBT2V8oe%2BMmS%2BI%2FHzcAsTFCYWDv6t6zT%2FWXFM%3D"
}
