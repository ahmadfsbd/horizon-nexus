#!/usr/bin/env python3
"""
Horizon Nexus — Playwright smoke test.

Usage:
    python check_ui.py [--release RELEASE_NAME]

Exit code 0 on pass, 1 on any assertion failure.
"""

import sys
import argparse
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

BASE_URL = "http://localhost:8080"


def run(release: str) -> bool:
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()

        try:
            # 1. Navigate to login page
            response = page.goto(f"{BASE_URL}/auth/login/", timeout=15_000)

            # 2. Assert HTTP 200
            if response.status != 200:
                print(f"FAIL [{release}]: Expected HTTP 200, got {response.status}")
                return False

            # 3. Assert page title contains "OpenStack" or "Nexus"
            title = page.title()
            if "OpenStack" not in title and "Nexus" not in title:
                print(f"FAIL [{release}]: Page title '{title}' does not contain "
                      "'OpenStack' or 'Nexus'")
                return False

            # 4. Assert id="nexus-nav" exists
            nav = page.query_selector("#nexus-nav")
            if nav is None:
                print(f"FAIL [{release}]: Element with id='nexus-nav' not found in DOM")
                return False

            # 5. Assert an img element exists inside the header (logo present)
            logo = page.query_selector("header img, #nexus-header img")
            if logo is None:
                print(f"FAIL [{release}]: No <img> element found inside the header")
                return False

            # 6. Assert no "Traceback" text (no Python exceptions rendered)
            if page.locator("text=Traceback").count() > 0:
                print(f"FAIL [{release}]: Page contains 'Traceback' — Python exception rendered")
                return False

            # 7. Assert no "500" text in heading context
            for tag in ["h1", "h2", "h3", "h4", "h5", "h6", "title"]:
                locator = page.locator(f"{tag}:has-text('500')")
                if locator.count() > 0:
                    print(f"FAIL [{release}]: Found '500' inside a <{tag}> element")
                    return False

            # 8. Assert no wordmark/brand-name text adjacent to the logo
            #    The logo <img> must have no sibling text nodes or text elements
            #    inside the same immediate container.
            logo_container = page.evaluate("""() => {
                const header = document.querySelector('#nexus-header, header');
                if (!header) return null;
                const brand = header.querySelector('.nexus-brand, a:has(img)');
                if (!brand) return null;
                // Collect all text content that is NOT inside the img itself
                let text = '';
                brand.childNodes.forEach(node => {
                    if (node.nodeType === Node.TEXT_NODE) {
                        text += node.textContent;
                    } else if (node.nodeType === Node.ELEMENT_NODE
                               && node.tagName !== 'IMG') {
                        text += node.innerText || node.textContent || '';
                    }
                });
                return text.trim();
            }""")

            if logo_container and logo_container.strip():
                print(f"FAIL [{release}]: Wordmark/brand text found beside logo: "
                      f"'{logo_container.strip()}'")
                return False

            print(f"PASS [{release}]: All smoke test assertions passed")
            return True

        except PWTimeout as exc:
            print(f"FAIL [{release}]: Timeout while loading page — {exc}")
            return False
        except Exception as exc:
            print(f"FAIL [{release}]: Unexpected error — {exc}")
            return False
        finally:
            browser.close()


def main():
    parser = argparse.ArgumentParser(description="Horizon Nexus UI smoke test")
    parser.add_argument("--release", default="unknown", help="Release name for log output")
    args = parser.parse_args()

    success = run(args.release)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
