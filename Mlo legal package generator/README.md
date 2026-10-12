# MLO Legal Package Generation Agent

A standalone browser prototype for reviewing synthetic mortgage-package information. It reads uploaded files locally in the browser and applies configured validation rules. It is not an official HEB system or legal document template.

## Run the app

1. Keep `index.html` and the `vendor` folder together.
2. For the standard deterministic app, open `index.html` in a modern browser such as Microsoft Edge or Google Chrome.
3. Review the pre-filled conditions in the first panel. Select **Edit** to change them.
4. Choose a PDF, DOCX, TXT, or Markdown file with **Browse Files**, or click **Try Demo File**.
5. Click **Submit & Generate Package**. A progress modal reports the current work and whether Ollama AI or predefined rules are being used. For very fast operations, it stays open for at least about 1.8 seconds so the progress is visible; longer operations remain visible until they finish. Uploaded field suggestions still require MLO review before the app evaluates the conditions and generates the draft.
6. The generated package appears in the third panel with case-detail tables, a supporting-document checklist, validation findings and follow-up actions. Use **Print / Save as PDF** to open the browser print dialog, then choose **Save as PDF**. The print layout includes the package only, with print-friendly tables and page breaks; the validation details remain below on the same page.
7. MLO review notes are optional; you can generate and print the package without entering any. If you add notes, select **Save MLO Notes** to add them to the on-screen package. Notes remain in memory for the current page session and are cleared when a new analysis starts or a different file/demo case is selected. **Print / Save Draft as PDF** always excludes notes. **Print MLO Review Copy** works with or without notes; saved notes are included only when you select the optional include-notes checkbox. Unsaved edits are never printed.

No application install or server is required. PDF.js is included locally in `vendor/pdfjs`, so PDF text extraction does not depend on a CDN or internet connection.

Do not enter confidential, personal, borrower, financial, or legal information in the notes. Use fictional demo information only. Browser print-to-PDF and operating-system tools run outside this application; the app cannot reliably prevent printing or saving content that is visible on screen.

## Optional AI extraction with Ollama

When Ollama AI is enabled, it is the primary field extractor for uploaded documents. It suggests the document type and field values, including values that may not follow the app's simple text-label patterns. The app checks that quoted evidence appears in the extracted document text, then shows the suggestions in an MLO review form. Review, edit, select, or clear the suggestions and confirm them before validation runs.

The first panel displays the default validation conditions. With those conditions unchanged, the existing deterministic checks run. If you edit a condition, the app identifies the affected check(s), sends only those checks with the edited conditions and a concise case-facts summary to Ollama's `/api/generate`, and keeps unchanged checks on the deterministic rules. Any requested check omitted by the model is marked **Unable to Verify**, never passed silently. An MLO must review the results. Edited conditions cannot be evaluated when the Ollama bridge/model is unavailable. If `.env` uses a remote endpoint, edited conditions and parsed case facts are sent to that provider. No raw uploaded file is sent by condition evaluation.

Requirements:

- Node.js installed.
- For local use: Ollama installed and running, with a model downloaded (for example, `ollama pull llama3.2:3b`).
- For remote use: an HTTPS Ollama endpoint, a model available on that endpoint, and its API key if required.

Configure the provider in `.env` in the project folder. The included `.env` selects local Ollama; `.env.example` shows the settings:

```dotenv
OLLAMA_BASE_URL=http://127.0.0.1:11434
OLLAMA_MODEL=llama3.2:3b
OLLAMA_API_KEY=
```

For a cloud/remote provider, set `OLLAMA_BASE_URL` to its HTTPS Ollama-compatible base URL, `OLLAMA_MODEL` to the exact model name listed by that endpoint, and `OLLAMA_API_KEY` to the provider key. Keep the key only in `.env`; it is ignored by Git and is never sent to the browser. The server sends it to Ollama as a Bearer token. Remote use requires HTTPS, and the health response does not expose the key. Never commit `.env` or share it.

To start and use the AI workflow:

1. For local mode, start Ollama and confirm the model with `ollama list`; for remote mode, confirm the base URL, model name, and key in `.env`.
2. Double-click `run-local-ai.bat` in this folder. **Restart the server after every `.env` change.**
3. Keep the server window open and browse to `http://127.0.0.1:4173`.
4. Confirm the page reports the configured model and provider mode. The AI option is enabled only when the configured endpoint is reachable and the model is available.
5. Upload a document and analyze it. With local mode, extracted text goes only to the local bridge and Ollama on this computer. With remote mode, extracted text is sent to the configured provider; use remote AI only if your organization's data-handling policy permits it.
6. Review the suggested document type and quoted evidence. When readable text contains a recognizable document heading, that heading takes precedence over an AI document-type suggestion based on incidental terms. AI-suggested fields start unchecked; select only the fields you verified, edit values if needed, and confirm the document type before clicking **Confirm selected fields and run checks**.

The bridge binds to `127.0.0.1` only. If Ollama is unavailable, turn off the AI option to review deterministic text-pattern suggestions. Structured synthetic manifests are parsed by deterministic rules without an AI call. Opening `index.html` directly continues to work without AI; use the local launcher to enable the optional Ollama connection.

## File support

- **TXT / Markdown:** Reads the selected file's text.
- **DOCX:** Reads text from the document body.
- **PDF:** Extracts selectable text using the included PDF.js library and reconstructs line breaks from text positions so text-based PDFs retain field and manifest boundaries.
- **Scanned/image-only PDFs:** OCR is not included. If a PDF contains no selectable text, analysis reports that it could not extract text.
- Password-protected, damaged, or unsupported documents may not be readable.

Uploaded files are read in the browser. With Ollama AI enabled, extracted document text is sent to the localhost bridge and then to the Ollama endpoint selected in `.env` (local or remote). Edited-condition evaluation sends the condition text and parsed case facts, not the uploaded text itself, to that endpoint. AI suggestions must be reviewed and confirmed by the MLO before validation. Without extraction AI, the app presents text-pattern suggestions for the same review and confirmation step. Neither AI nor text patterns independently verify source documents or facts.

## Sample files and scenarios

- `correct-sample-document.txt` — a synthetic package manifest expected to pass the configured checks.
- `negative-sample-document.txt` — a synthetic package manifest with a property-address mismatch and differing balance/payout values.
- `demo-commitment-within-limit.txt` and `demo-commitment-over-limit.txt` — fictional commitment-letter documents for demonstrating an edited approved-amount condition (CAD 325,000 versus CAD 410,000).
- **Try Demo File** — the built-in HEB-DEMO-10248 synthetic case.
- **Try Missing Documents Scenario** — demo case with the debt statement and property tax statement unavailable.
- **Try Address Mismatch Scenario** — demo case with different commitment and mortgage-statement addresses.

The sample manifests explicitly declare seven supporting-document records for testing. They are fictional declarations, not the underlying source documents, and are not independently verified. A normal single uploaded document only establishes information from that document; it does not establish that other supporting documents were provided.

### Demo an edited validation condition

In **Review Conditions**, replace only the first condition with the rule below and leave the remaining conditions unchanged:

```text
1. Mortgage commitment: require a supplied approval or commitment source. Compare the approved amount with CAD 350,000: Pass if it is CAD 350,000 or less; if it is greater than CAD 350,000, mark Attention Required.
```

Use **Edit** to change the conditions, then select **Done editing**. Upload one of the two commitment-letter files using **Browse Files** and click **Submit & Generate Package**. On the extraction review screen, verify the document type and approved amount against the displayed evidence, select the document-type confirmation checkbox, and confirm the approved-amount field is selected before continuing.

Expected demo outcome: the CAD 325,000 example should meet the stated limit; the CAD 410,000 example should be flagged for attention. The edited commitment check is assessed by configured Ollama, so keep `run-local-ai.bat` running and confirm the model is available. The other checks still report only what can be established from the single uploaded commitment letter. All files and outcomes are synthetic and require human review.

## Prototype boundaries

- No MARS or other production-system integration.
- No emails are sent; the email section is a copyable draft only.
- No external verification of identity, property ownership, insurance, debt, or tax information.
- Validation results are for demonstration and human review only, not legal advice, approval, or authorization to issue legal instructions.
- The generated package is a formatted demo preview, not an official HEB template. Its tables organize the available information and configured-check results for review; they do not imply source verification or legal approval.

## Main files

- `index.html` — application UI, local document reading, and validation logic.
- `.env` / `.env.example` — active Ollama endpoint settings and a safe configuration template.
- `server.js` and `run-local-ai.bat` — optional loopback-only app server and bridge to configured Ollama.
- `vendor/pdfjs/pdf.min.js` and `vendor/pdfjs/pdf.worker.min.js` — local PDF text-extraction library and worker.
- `vendor/pdfjs/LICENSE` — PDF.js license.
