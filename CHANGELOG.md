# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/compare/v1.1.0...v1.1.1) (2026-04-01)


### Bug Fixes

* **iam:** add destroy-time polling and switch to role_policy_attachment ([42b004c](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/42b004c333777db6d9b331a768b7f6ed5faf96c2))
* **iam:** add destroy-time polling and switch to role_policy_attachment ([dd5fa55](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/dd5fa55f1d7cafdcf5966b5f89b1f0394c6e00ac))
* **iam:** improve destroy hygiene and add consistency delay ([18138e3](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/18138e3e146712ba95a7938392bc9074ce53fc82))


### Documentation

* update terraform-docs generated content ([6123147](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/6123147c84d9be5698734b8b931757cfa659fb1b))

## [1.1.0](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/compare/v1.0.0...v1.1.0) (2026-01-28)


### Features

* **01-01:** convert to release-please from semantic-release ([093492b](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/093492b6a535808bfc652e953dcf6e3851f6c277))
* **03-02:** add IAM baseline security configs ([a19762f](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/a19762fbaefb713b7e4fa16237d205e90af4c0f8))
* **03-02:** add IAM security scanning workflow ([f915c0c](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/f915c0cb405f45c974011768ab605d6456cff07c))
* **05-01:** add integration test workflow for IAM module ([b14c888](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/b14c88801d91fa472998fb0e8633fa5218eb5c6b))
* **05-01:** create integration test fixture for IAM module ([03d7e09](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/03d7e0906ee464260f54c50039ba4aeaae3bad31))
* **05-02:** add scheduled cleanup workflow for orphaned test resources ([ab926e2](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/ab926e2cca285f0238d9b7ca2fe68a73b3679ed5))
* **ci:** add format, validate, and lint workflow ([ee5efa5](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/ee5efa522875dd9ba022917882a5e9053be8bd63))


### Bug Fixes

* **01-01:** use GITHUB_TOKEN with repository_dispatch for Release PR CI ([9e269fe](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/9e269fefc91a756fc9ab3f5f946946e950766ce2))
* **ci:** broaden path filter to trigger CI on all workflow changes ([5948689](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/59486896d8538914b862c6d8fc18164f35e35af9))
* **ci:** remove path filter from pull_request trigger ([ca29e36](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/ca29e363bba599adbaf0bd4c3aa8b5cfdbff71cb))
* **ci:** resolve release-please JSON parsing issue ([ebb4ff9](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/ebb4ff91f1be46949f1efa3e224fe864d9abbc92))
* **ci:** resolve release-please JSON parsing issue ([eec38f9](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/eec38f978b17e8a44b52a93ba3df3b0723455ccc))


### Documentation

* **01-02:** add CONTRIBUTING.md with Conventional Commits section ([44cc75d](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/44cc75d29fda2897ad89cfe0e36ee9e59d1c08fa))
* **04-02:** add terraform-docs config and update README ([dd6282e](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/dd6282e303f1d1e4f69c00d0e9cd79a2906cdd1c))

## 1.0.0 (2025-01-17)


### Features

* initial commit ([936c8f4](https://github.com/zadarastorage/terraform-zcompute-iam-instance-profile/commit/936c8f455d4f23fc1dad70d0070d736c522ae26e))
