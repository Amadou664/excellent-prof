import * as Sentry from "@sentry/node";
import { env } from "./config/env";

// Doit rester le tout premier import de src/index.ts (avant express et le reste), sinon
// l'auto-instrumentation de Sentry sur les modules deja charges ne fonctionne pas. Sans
// SENTRY_DSN configure (compte pas encore cree, voir README), ce module ne fait rien : aucune
// erreur, le reste de l'app tourne normalement.
if (env.sentryDsn) {
  Sentry.init({
    dsn: env.sentryDsn,
    environment: env.nodeEnv,
  });
}
