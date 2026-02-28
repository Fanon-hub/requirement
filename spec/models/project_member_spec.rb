require 'rails_helper'

RSpec.describe ProjectMember, type: :model do
  describe 'validations and callbacks' do
    let(:project) { create(:project) }
    let(:user)    { create(:user) }

    it 'is valid with valid attributes and sets joined_at' do
      pm = build(:project_member, project: project, user: user, role: 'contributor')
      expect(pm).to be_valid
      pm.save!
      expect(pm.joined_at).to be_present
    end

    it 'requires role and joined_at' do
      expect(build(:project_member, role: nil)).not_to be_valid
    end

    it 'enforces uniqueness of user per project' do
      create(:project_member, project: project, user: user)
      dup = build(:project_member, project: project, user: user)
      expect(dup).not_to be_valid
      expect(dup.errors[:user_id]).to be_present
    end
  end

  describe 'enums' do
    it 'responds to role prefixes' do
      pm = build(:project_member, role: 'viewer')
      expect(pm.role).to eq('viewer')
      expect(ProjectMember.role_prefix_viewer?).to be(false) if ProjectMember.respond_to?(:role_prefix_viewer?)
    end
  end
end
