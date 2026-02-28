require 'rails_helper'

RSpec.describe TaskComment, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:task_comment)).to be_valid
    end

    it 'is invalid without comment_text' do
      comment = build(:task_comment, comment_text: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:comment_text]).to be_present
    end

    it 'is invalid when comment_text is too long' do
      expect(build(:task_comment, comment_text: 'a' * 1001)).not_to be_valid
    end
  end

  describe 'scopes' do
    it '.recent orders by created_at desc' do
      older = create(:task_comment, created_at: 2.days.ago)
      newer = create(:task_comment, created_at: 1.day.ago)
      expect(TaskComment.where(id: [older.id, newer.id]).recent.first).to eq(newer)
    end
  end
end
