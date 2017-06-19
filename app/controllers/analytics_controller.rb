require 'net/http'
require 'json'
require 'active_support/time'

class AnalyticsController < ApplicationController
	@@access_token = "1310745515710301%7Cu1tg9K6caKp76vp80EAXmyHbcnE"

	def index
		# savePostsInDatabase
		Post.all.each do |post|
			# saveLikes(post,"likes")
			# saveComments(post)
			saveShares(post)
		end
	end

	def saveLikes(post)
		#If a post with certain action has already been stored then it will not be repeated.
		if Post.where(:post_id=>post.post_id)[0].actions.where(:name=>"like").count!=0 then
			return
		end

		domain = "https://graph.facebook.com/v2.9/"+post.post_id+"/likes?limit=100000&access_token="+@@access_token
		response = getDataFromGraphApi(domain)

		count = post.actions.where(:name=>"like").count
		current_action = nil
		if count==0 then
			current_action = post.actions.create(:name=>"like",:post_id=>post.post_id)
		else
			current_action = post.actions.where(:name=>"like")[0]
		end

		while true do
			response["data"].each do |like|
				if User.where(:facebook_id=>like["id"]).count==0 then
					user = User.create(:facebook_id=>like["id"])
					current_action.users<<user
				else
					current_action.users<<User.where(:facebook_id=>like["id"])[0]
				end
			end

			if response["paging"].key?("next") then
				response = getDataFromGraphApi(response["paging"]["next"])
			else
				break
			end
		end

	end

	def saveComments(post)
		#If a post with certain action has already been stored then it will not be repeated.
		if Post.where(:post_id=>post.post_id)[0].actions.where(:name=>"comment").count!=0 then
			return
		end

		domain = "https://graph.facebook.com/v2.9/"+post.post_id+"/comments?limit=100000&access_token="+@@access_token
		response = getDataFromGraphApi(domain)

		count = post.actions.where(:name=>"comment").count
		current_action = nil
		if count==0 then
			current_action = post.actions.create(:name=>"comment",:post_id=>post.post_id)
		else
			current_action = post.actions.where(:name=>"comment")[0]
		end

		while true do
			response["data"].each do |comment|
				if User.where(:facebook_id=>comment["from"]["id"]).count==0 then
					user = User.create(:facebook_id=>comment["from"]["id"])
					current_action.users<<user
				else
					current_action.users<<User.where(:facebook_id=>comment["from"]["id"])[0]
				end
			end

			if response.key?("paging") and response["paging"].key?("next") then
				response = getDataFromGraphApi(response["paging"]["next"])
			else
				break
			end
		end

	end

	def saveShares(post)
		#If a post with certain action has already been stored then it will not be repeated.
		if Post.where(:post_id=>post.post_id)[0].actions.where(:name=>"share").count!=0 then
			return
		end

		domain = "https://graph.facebook.com/v2.9/"+post.post_id+"/sharedposts?limit=100000&access_token="+@@access_token
		response = getDataFromGraphApi(domain)

		count = post.actions.where(:name=>"share").count
		current_action = nil
		if count==0 then
			current_action = post.actions.create(:name=>"share",:post_id=>post.post_id)
		else
			current_action = post.actions.where(:name=>"share")[0]
		end
		puts JSON.pretty_generate(response)
		while true do
			response["data"].each do |share|
				# if User.where(:facebook_id=>share["from"]["id"]).count==0 then
				# 	user = User.create(:facebook_id=>share["from"]["id"])
				# 	current_action.users<<user
				# else
				# 	current_action.users<<User.where(:facebook_id=>share["from"]["id"])[0]
				# end
			end

			if response.key?("paging") and response["paging"].key?("next") then
				response = getDataFromGraphApi(response["paging"]["next"])
			else
				break
			end
		end

	end

	def savePostsInDatabase
		domain = "https://graph.facebook.com/v2.9/222530618111374/feed?limit=100&access_token="+@@access_token
		response = getDataFromGraphApi(domain)
		while true do
			puts JSON.pretty_generate(response)
			flag=false
			response["data"].each do |post|
				if Time.parse(post["created_time"]) < Time.now-7.day then
					flag=true
					break
				end
				count = Post.where(:post_id=>post["id"]).count
				if count==0 then
					Post.create(post_id: post["id"], timestamp: post["created_time"])
				end
			end
			if flag then
				break
			end
			if response.key?("paging") and response["paging"].key?("next") then
				response = getDataFromGraphApi(response["paging"]["next"])
			else
				break
			end
		end
	end

	def getDataFromGraphApi(domain)
		uri = URI.parse(domain)
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		http.use_ssl = true  
		response = http.request(request)
		response = JSON.parse(response.body)
		return response
	end
end