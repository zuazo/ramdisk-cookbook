ramdisk CHANGELOG
=================

This file is used to list changes made in each version of the `ramdisk` cookbook.

## v0.2.1 (2015-08-26)

* README: Fix coverage badge.

## v0.2.0 (2015-08-26)

* `LwrpHelpers`: improve similar code using delegation.
* Gemfile: Update RuboCop to `0.33.0` ([issue #1](https://github.com/zuazo/ramdisk-cookbook/pull/1), thanks [Hendrik Bergunde](https://github.com/hendrikb)).
* metadata: Add `source_url` and `issues_url`.

* Documentation:
 * Update chef links to use *chef.io* domain.
 * Update contact information and links after migration.
 * README: Put the cookbook name in the title.
 * Document the Rakefile.
 * Move the ChefSpec matchers documentation to the README.

* Testing:
 * Travis: Run tests against Chef 11 and Chef 12.
 * Rakfile: Add clean task.
 * Fix ChefSpec tests.
 * Fix integration tests for Ubuntu `15.04` and OpenSUSE.
 * Move ChefSpec tests to *test/unit*.

## v0.1.0 (2014-11-24)

* Initial release of `ramdisk`.
