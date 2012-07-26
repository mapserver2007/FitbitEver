# -*- coding: utf-8 -*-
$: << File.dirname(__FILE__) + "/evernote/lib"
$: << File.dirname(__FILE__) + "/evernote/lib/thrift"
$: << File.dirname(__FILE__) + "/evernote/lib/Evernote/EDAM"

require "thrift/types"
require "thrift/struct"
require "thrift/protocol/base_protocol"
require "thrift/protocol/binary_protocol"
require "thrift/transport/base_transport"
require "thrift/transport/http_client_transport"
require "Evernote/EDAM/user_store"
require "Evernote/EDAM/user_store_constants.rb"
require "Evernote/EDAM/note_store"
require "Evernote/EDAM/limits_constants.rb"
require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'

module FitbitEver
  EVERNOTE_URL = "https://www.evernote.com/edam/user"
  
  class MyEvernote
    def initialize(auth_token)
      @auth_token = auth_token
      userStoreTransport = Thrift::HTTPClientTransport.new(EVERNOTE_URL)
      userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
      user_store = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)
      noteStoreUrl = user_store.getNoteStoreUrl(@auth_token)
      noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
      noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
      @note_store = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
    end
    
    def add_note(data, notebook, stack = nil, tags)
      note = Evernote::EDAM::Type::Note.new
      note.title = to_ascii(24.hours.ago.strftime("%Y年%m月%d日") + "のアクティビティ")
      note.content = create_content(data)
      note.notebookGuid  = get_notebook_guid(notebook, stack)
      note.tagGuids = get_tag_guid(tags)
      @note_store.createNote(@auth_token, note)
    end
    
    private
    def to_ascii(str)
      str.force_encoding("ASCII-8BIT") unless str.nil?
    end
    
    def get_notebook_guid(notebook_name, stack_name = nil)
      notebook_name = to_ascii(notebook_name)
      stack_name = to_ascii(stack_name)
      @note_store.listNotebooks(@auth_token).each do |notebook|
        if notebook.name == notebook_name && notebook.stack == stack_name
          return notebook.guid
        end
      end
    end
    
    def get_tag_guid(tag_list)
      tag_list.map!{|tag| to_ascii(tag)}
      @note_store.listTags(@auth_token).each_with_object [] do |tag, list|
        if tag_list.include? tag.name
          list << tag.guid
        end
      end
    end
    
    def create_content(hash)
      xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + 
      "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\">" +
      "<en-note>%s</en-note>"
      html = ""
      hash.each {|key, value| html << "<div><![CDATA[#{key}: #{to_ascii(value)}]]></div>"}
      xml % html
    end
  end
end

