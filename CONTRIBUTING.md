# Contributing

1. Open an issue describing the failure, expected behavior and minimal reproduction.
2. Never include credentials, tokens, student data, audio recordings or unredacted response bodies.
3. Keep changes scoped and add offline tests for parsing and state logic.
4. Run `python -m unittest discover -s tests -v` and `python -m compileall -q src tests`.
5. Explain what was tested locally and what still needs live-account verification.

Tests and CI must not log in to FiF or submit recordings. Changes to selectors, authentication and task response schemas should include redacted structural fixtures.
