class CreateTranslationUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Translation, :uuid, force: true
  end

  def down
    drop_constraint :Translation, :uuid
  end
end
