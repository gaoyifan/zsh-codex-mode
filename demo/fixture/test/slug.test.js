import assert from "node:assert/strict";
import test from "node:test";

import { slugify } from "../src/slug.js";

test("converts spaces to hyphens", () => {
  assert.equal(slugify("Hello World"), "hello-world");
});
