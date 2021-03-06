class ElearningSecretaryPlugin::DocumentSerializer < ActiveModel::Serializer

  attributes :profile
  attributes :id, :name

  def profile
    profile = self.object.profile
    {id: profile.id, name: profile.name}
  end

end

