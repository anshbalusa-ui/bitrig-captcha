import http from "node:http";
import crypto from "node:crypto";

const PORT = Number(process.env.PORT ?? 8787);
const SECRET =
  process.env.CAPTCHA_SECRET ??
  crypto.randomBytes(32).toString("hex");

const challenges = new Map();

function json(res, status, body) {
  res.writeHead(status, {
    "content-type": "application/json",
    "cache-control": "no-store",
    "access-control-allow-origin": "*",
    "access-control-allow-headers": "content-type",
    "access-control-allow-methods": "GET,POST,OPTIONS",
  });
  res.end(JSON.stringify(body));
}

function randomAngle(exclude = []) {
  const choices = [];

  for (let angle = 45; angle <= 145; angle += 1) {
    if (
      exclude.every(
        (existing) =>
          Math.abs(existing - angle) >= 25,
      )
    ) {
      choices.push(angle);
    }
  }

  return choices[
    crypto.randomInt(0, choices.length)
  ];
}

function createChallenge() {
  const first = randomAngle();
  const second = randomAngle([first]);
  const third = randomAngle([first, second]);

  const id = crypto.randomUUID();
  const now = Date.now();

  const challenge = {
    id,
    createdAt: now,
    expiresAt: now + 60_000,
    targets: [
      {
        angle: first,
        tolerance: 3,
        holdDurationMs: 0,
      },
      {
        angle: second,
        tolerance: 3,
        holdDurationMs: 0,
      },
      {
        angle: third,
        tolerance: 3,
        holdDurationMs: 750,
      },
    ],
  };

  challenges.set(id, challenge);
  return challenge;
}

function inRange(sample, target) {
  return (
    Math.abs(sample.angle - target.angle) <=
    target.tolerance
  );
}

function validateTrajectory(
  challenge,
  samples,
) {
  if (
    !Array.isArray(samples) ||
    samples.length < 8
  ) {
    return false;
  }

  let cursor = 0;
  let previousCompletionIndex = -1;

  for (const target of challenge.targets) {
    let entryIndex = -1;

    for (
      let index = cursor;
      index < samples.length;
      index += 1
    ) {
      if (inRange(samples[index], target)) {
        entryIndex = index;
        break;
      }
    }

    if (entryIndex < 0) {
      return false;
    }

    let completionIndex = entryIndex;

    if (target.holdDurationMs > 0) {
      const startedAt =
        samples[entryIndex].timestampMs;

      let completed = false;

      for (
        let index = entryIndex;
        index < samples.length;
        index += 1
      ) {
        const sample = samples[index];

        if (!inRange(sample, target)) {
          break;
        }

        if (
          sample.timestampMs - startedAt >=
          target.holdDurationMs
        ) {
          completionIndex = index;
          completed = true;
          break;
        }
      }

      if (!completed) {
        return false;
      }
    }

    if (previousCompletionIndex >= 0) {
      const segment = samples.slice(
        previousCompletionIndex,
        completionIndex + 1,
      );

      const angles = segment.map(
        (sample) => sample.angle,
      );

      const movement =
        Math.max(...angles) -
        Math.min(...angles);

      if (movement < 5) {
        return false;
      }
    }

    previousCompletionIndex =
      completionIndex;
    cursor = completionIndex + 1;
  }

  return true;
}

function signToken(payload) {
  const encoded = Buffer.from(
    JSON.stringify(payload),
  ).toString("base64url");

  const signature = crypto
    .createHmac("sha256", SECRET)
    .update(encoded)
    .digest("base64url");

  return `${encoded}.${signature}`;
}

async function readBody(req) {
  const chunks = [];

  for await (const chunk of req) {
    chunks.push(chunk);
  }

  if (chunks.length === 0) {
    return {};
  }

  return JSON.parse(
    Buffer.concat(chunks).toString("utf8"),
  );
}

const server = http.createServer(
  async (req, res) => {
    try {
      if (req.method === "OPTIONS") {
        json(res, 204, {});
        return;
      }

      if (
        req.method === "POST" &&
        req.url === "/api/challenge"
      ) {
        json(res, 200, createChallenge());
        return;
      }

      if (
        req.method === "POST" &&
        req.url === "/api/verify"
      ) {
        const body = await readBody(req);
        const challenge =
          challenges.get(body.challengeId);

        if (
          !challenge ||
          Date.now() > challenge.expiresAt
        ) {
          json(res, 400, {
            verified: false,
            reason:
              "Challenge missing or expired",
          });
          return;
        }

        // One attempt per challenge prevents replay.
        challenges.delete(challenge.id);

        const verified =
          validateTrajectory(
            challenge,
            body.samples,
          );

        if (!verified) {
          json(res, 400, {
            verified: false,
            reason:
              "Trajectory did not match challenge",
          });
          return;
        }

        const expiresAt = Date.now() + 30_000;

        const token = signToken({
          challengeId: challenge.id,
          verifiedAt: Date.now(),
          expiresAt,
          nonce: crypto.randomUUID(),
        });

        json(res, 200, {
          verified: true,
          token,
          expiresAt,
        });
        return;
      }

      json(res, 404, {
        error: "Not found",
      });
    } catch (error) {
      json(res, 500, {
        error:
          error instanceof Error
            ? error.message
            : "Unknown server error",
      });
    }
  },
);

server.listen(PORT, () => {
  console.log(
    `Fold CAPTCHA demo backend listening on http://localhost:${PORT}`,
  );
});
