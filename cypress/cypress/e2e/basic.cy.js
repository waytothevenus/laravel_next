describe("Basic test", () => {
  it("visits the home page", () => {
    cy.visit("/");
    cy.contains("NB Training"); // checks if there's an h1 element
  });
});
