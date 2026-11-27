# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Minor features that don't break backwards compatibility are released as patches.

## Unreleased

### Changed

- A node's response headers are only made when it adds one, and its content type is found by looking through its headers rather than indexing them all
- An action's keywords are passed as they are when its method takes all of them, rather than copied

## 0.5.16

### Added

- `handles?(action)` says whether a node does anything for an action, like a `side_effect` it defines, so a router can skip events no node handles

### Changed

- An action without a body, like a `side_effect` a node doesn't have, no longer makes response headers it won't send

## 0.5.15

### Changed

- The keywords each node method takes are read once for each method, rather than on every render

## 0.5.14

### Fixed

- A JSON response and one an action made itself join the request's event tree like an HTML one, so a dashboard can see the request was answered

## 0.5.13

### Changed

- HTML a node renders is stripped in place rather than copied, so a large page uses less memory. A frozen string, like a literal an action returns, is copied as before

## 0.5.12

### Added

- `tick`, which a node defines to run each time an interval it observes is due, like `observe Interval[every_minute: 5]`. Only a node that defines it is initialized, and what it returns is ignored

## 0.5.11

### Fixed

- Text an action returns is sent with the content type the node added with `add_header`, like `text/plain` for a robots.txt, instead of always `text/html`

## 0.5.10

### Added

- An action can return a hash or an array, which is sent as JSON, or a `Protocol::HTTP::Response` it made itself, which is sent as it is. Either way the headers the node set, like its cookies, are added
- `add_header(name, value)` adds a header to a node's response, like `set_cookie` adds a cookie, for an action that returns its body

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
