# Security Notes

This repository is a hackathon prototype of a new physical interaction for CAPTCHA-style verification.

## What the prototype demonstrates

- randomized hinge targets
- continuous angle sampling
- ordered trajectory validation
- hold validation
- short-lived verification results
- a Duo-native physical interaction

## What it does not claim

The local iOS implementation is **not** a production-grade anti-bot system. A modified client could potentially fake local sensor readings or bypass client-side checks.

A real deployment should:

1. create challenges on a trusted server
2. bind each challenge to a requesting session/action
3. expire challenges quickly
4. validate the uploaded trajectory server-side
5. use signed, one-time verification tokens
6. rate-limit challenge creation and verification
7. add replay protection
8. avoid storing more sensor data than necessary

The optional `backend/` demo server shows the shape of this flow, but it is intentionally small and in-memory for hackathon use.
