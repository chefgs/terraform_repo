##############################################################################
# Oracle Cloud Infrastructure – Basic Compute with Networking
#
# Resources created:
#   - VCN with Internet Gateway and Route Table
#   - Public Subnet with Security List (allow SSH + HTTP/HTTPS)
#   - Compute Instance (VM) with optional SSH key
##############################################################################

# ── Availability Domain data source ────────────────────────────────────────
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# ── Latest Oracle Linux image ───────────────────────────────────────────────
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = var.os_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux.*$"]
    regex  = true
  }
}

# ── VCN ────────────────────────────────────────────────────────────────────
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-vcn"
  cidr_block     = var.vcn_cidr_block
  dns_label      = replace(var.project_name, "-", "")
}

# ── Internet Gateway ────────────────────────────────────────────────────────
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.project_name}-igw"
  enabled        = true
}

# ── Route Table ─────────────────────────────────────────────────────────────
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.project_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# ── Security List ───────────────────────────────────────────────────────────
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.project_name}-public-sl"

  # Allow all outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow inbound SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow inbound HTTP
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # Allow inbound HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Allow ICMP (ping)
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# ── Subnet ─────────────────────────────────────────────────────────────────
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn.id
  display_name      = "${var.project_name}-public-subnet"
  cidr_block        = var.subnet_cidr_block
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
  dns_label         = "public"

  # Public subnet – no prohibit_public_ip_on_vnic
  prohibit_public_ip_on_vnic = false
}

# ── Compute Instance ────────────────────────────────────────────────────────
resource "oci_core_instance" "compute" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.project_name}-instance"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gb
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = true
    display_name     = "${var.project_name}-vnic"
    hostname_label   = replace(var.project_name, "-", "")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(var.cloud_init_script)
  }

  freeform_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
