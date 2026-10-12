# Security policy

Please report suspected vulnerabilities privately through GitHub's security advisory reporting for this repository. Include affected versions, impact, and a reproducible example when possible. Do not post credentials or sensitive personal information in a public issue.

The library has no network client and no runtime gem dependencies. Treat user-provided paths as application input, validate them before use, and do not render untrusted HTML outside the provided escaped calendar renderers.
