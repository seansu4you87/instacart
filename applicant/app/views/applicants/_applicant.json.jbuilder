json.extract! applicant, :id, :first_name, :last_name, :email, :phone, :zipcode, :referral_code, :created_at, :updated_at
json.url applicant_url(applicant, format: :json)
