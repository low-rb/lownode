# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Minor features that don't break backwards compatibility are released as patches.

## Unreleased

### Added

- An action can return a hash or an array, which is sent as JSON, or a `Protocol::HTTP::Response` it made itself, which is sent as it is. Either way the headers the node set, like its cookies, are added

## 0.5.9

### Added

- A component rendered inside a template gets the template's render context

### Changed

- Need Antlers 1.5.3, which passes the render context on to components

## 0.5.8

### Added

- `set_cookie(name, value, **options)` sets a cookie with the node's response, `HttpOnly`, `Secure` and `SameSite=Lax` by default
- Return `redirect(location)` from an action to redirect, with a 303 by default
- `response_headers` for any other headers a node sends with its response

## 0.5.6

### Added

- Call `receive` and `side_effect` actions on the node instance like `render`
- `include Controller` to call HTTP verb actions (`get`, `post`, etc) on the node instance
- Respond with the status of a returned `Status[code], or a returned `ResponseEvent`

## 0.5.0

### Added

- Ignore nil and empty responses
- Handle multiple args when not RBX

## 0.4.0

## Changed

- Support omittable arguments
- Store namespace on AST parse

## 0.3.0

### Added

- Pass event param into template
- Render node without event arg when param not present
- Provide node count stat

### Changed

- Rename load template to build template

## 0.2.1

### Added

- No need to error when calling default methods

## 0.2.0

### Added

- Support RBX, Antlers and templates

## 0.1.0

### Added

- Handle events
