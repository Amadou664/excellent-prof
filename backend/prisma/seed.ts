import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("Seed: creation d'annonces d'exemple...");

  await prisma.annonce.createMany({
    data: [
      {
        titre: "Bienvenue sur L'Excellent Prof",
        contenu:
          "La plateforme de mise en relation profs/eleves au Mali est desormais ouverte. " +
          "Inscrivez-vous pour trouver un professeur ou proposer vos services.",
        type: "INFO",
        visibilite: "PUBLIC",
      },
      {
        titre: "Recrutement de professeurs qualifies",
        contenu:
          "Nous recherchons des enseignants dans toutes les matieres, tous niveaux " +
          "(fondamental, college, lycee, superieur). Deposez votre candidature depuis l'application.",
        type: "RECRUTEMENT",
        visibilite: "PUBLIC",
      },
      {
        titre: "Resultats de la campagne 'Cours pour tous'",
        contenu:
          "Felicitations aux eleves ayant participe a notre premiere campagne de soutien " +
          "scolaire gratuit. Retrouvez le calendrier des prochaines sessions ci-dessous.",
        type: "RESULTAT",
        visibilite: "CONNECTES",
      },
    ],
  });

  console.log("Seed: creation d'un cours pour tous d'exemple...");

  const dateDebut = new Date();
  dateDebut.setDate(dateDebut.getDate() + 14);
  const dateFin = new Date(dateDebut);
  dateFin.setHours(dateFin.getHours() + 3);

  await prisma.coursPourTous.create({
    data: {
      titre: "Cours de soutien gratuit — Mathematiques (Fondamental)",
      description:
        "Session gratuite de revision en mathematiques ouverte a tous les eleves du " +
        "fondamental, animee par des professeurs volontaires de L'Excellent Prof.",
      matiere: "Mathematiques",
      dateDebut,
      dateFin,
      tarif: 0,
      placesDisponibles: 30,
    },
  });

  console.log("Seed termine.");
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
