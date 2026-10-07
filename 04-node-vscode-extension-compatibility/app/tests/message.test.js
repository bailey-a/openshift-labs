import { describe, expect, it } from "vitest";
import { getMessage } from "../src/message.js";

describe("getMessage", () => {
  it("returns the baseline response", () => {
    expect(getMessage()).toBe("Hello from Node REST");
  });

  it("supports an alternate response mode", () => {
    expect(getMessage("LIVE")).toBe("Hello from Node LIVE");
  });
});
