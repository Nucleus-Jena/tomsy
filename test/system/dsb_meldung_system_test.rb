require "application_system_test_case"
require "integration_test_helper"
require "system_test_helper"

# Im Rahmen dieser Maßnahme verarbeitet DSB-Nutzer eine Missbrauchsmeldung,
# die sich auf eine dortige Anzeige bezieht. Jedoch trifft er nicht selbst die Entscheidung,
# sondern bittet Nutzer1 als Experten darum, dies zu tun.
class DsbMeldungSystemTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    # Run all jobs during this Smoke Test to update visibilies etc.
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
  end

  test "DSB-Missbrauchsmeldung Smoke-Test" do
    # Schritt 1 (fehlerhafte Anmeldung)
    #
    # Der DSB-Nutzer versucht, sich in das System einzuloggen, gibt hierbei jedoch das falsche Passwort ein,
    # was zu einer Fehlermeldung führt.
    login_using_form_with("dsb@uni-jena.example.org", "das falsche passwort")
    assert_text "E-Mail oder Passwort ungültig."

    # Schritt 2 (erfolgreiche Anmeldung)
    #
    # Nachdem dem DSB-Nutzer sein Fehler dank der Fehlermeldung aufgefallen ist, loggt er sich mit dem korrekten
    # Passwort ein und wird zu seiner Startseite weitergeleitet.
    login_using_form_with("dsb@uni-jena.example.org", "password")
    assert_button("user-menu") # We are logged in
    assert_current_path "/ambitions"

    # Schritt 3 (Starten einer Maßnahme zur Verarbeitung der Missbrauchsmeldung)
    #
    # DSB-Nutzer hatte sich in TOMSY eingeloggt, da er per E-Mail eine Missbrauchsmeldung erhalten hatte. Diese will er
    # jetzt in TOMSY weiter verarbeiten. Dazu startet er eine Maßnahme der Vorlage “DSB Meldung Missbrauch V1”.  Durch das
    # Starten gelangt er automatisch auf die Seite der neuen Maßnahme und wird als Verantwortlicher zugewiesen.
    within("header.v-toolbar") { click_on "Maßnahmen" }
    click_on "Maßnahme starten"
    click_menu_list_item "DSB Meldung Missbrauch V1"
    click_menu_card_action_button "STARTEN"

    assert_current_path(/processes\/\d+/)
    assert within(right_sidebar) { control_for("Verantwortlicher").has_text?("dsb@uni-jena.example.org") }

    # Schritt 4 (Privatsphäre-Einstellung)
    #
    # Da es sich bei dem vorliegenden Fall um ein sensibles Thema mit personenbezogenen Daten handelt, stellt der
    # DSB-Nutzer die Sichtbarkeit der Maßnahme auf privat.
    within(right_sidebar) { find(".v-input", text: "Privat").click }

    # Schritt 5 (Ziel zuweisen)
    #
    # Das DSB-Team hat sich das Ziel gesetzt, die Missbrauchsmeldungen so schnell wie möglich zu bearbeiten.
    # Um dies zu kontrollieren wird die neue Maßnahme diesem Ziel zugewiesen.
    within right_sidebar do
      within control_for("Ziele") do
        click_on "Ändern"
        fill_in "Suche", with: "Missbrauchsmeldungen"
        find(".v-list-item", text: "Keine offenen Missbrauchsmeldungen").click
      end
      assert control_for("Ziele").has_text?("Keine offenen Missbrauchsmeldungen")
    end

    # Schritt 6 (Titel und Beschreibung)
    #
    # Die Maßnahme wird mithilfe von Titel und Beschreibung kurz genauer beschrieben.
    open_title_and_description_card
    new_title = "Oper Leipzig"
    new_description = "Verkauf von Ehrenamtskarten der Oper Leipzig."
    fill_in_title_and_description new_title, new_description
    click_title_and_description_edit_button "SPEICHERN"

    assert_text new_title
    assert_text new_description

    # Schritt 7 (Beginn der Eingabe der Daten für die erste Aufgabefehlerhafte Mailadresse eingeben)
    #
    # Um die Missbrauchsmeldung zu erfassen, wird zunächst die Mailadresse des Absenders hinterlegt.
    # Diese wird aus Unachtsamkeit im falschen Format eingegeben.
    within(left_sidebar) { click_on("Missbrauchshinweis aufnehmen") }
    assert middle_area.has_text?("Missbrauchshinweis aufnehmen")
    within right_sidebar do
      within(control_for("Verantwortlicher")) do
        click_on "Ändern"
        fill_in "Suche", with: "DSB"
        find(".v-list-item", text: "dsb@uni-jena.example.org").click
      end
      assert control_for("Verantwortlicher").has_text?("dsb@uni-jena.example.org")
    end

    within(middle_area) do
      within(find(".v-input", text: "E-Mail-Adresse Absender")) do
        fill_in "E-Mail-Adresse Absender", with: "somebody@emailprovider\n"
        assert has_text? "ist nicht gültig"
      end
    end

    # Schritt 8 (Vollständige Eingabe der Daten für die Aufgabe Missbrauchshinweis aufnehmen)
    #
    # Anschließend werden alle Datenfelder in der Aufgabe “Missbrauchshinweis aufnehmen” korrekt eingegeben.
    within(middle_area) do
      within(find(".v-input", text: "E-Mail-Adresse Absender")) do
        fill_in "E-Mail-Adresse Absender", with: "somebody@emailprovider.co.uk"
      end
      within(find(".v-input", text: "Text der E-Mail")) do
        fill_in "Text der E-Mail", with: <<~EOF
          Es handelt sich hierbei um eine Veranstaltung bei der ehrenamtlich Tätige eingeladen werden, um deren Einsatz und Engagement zu würdigen. 
          Die Einladungen sind personengebunden. Eine Weitergabe der Einladung und Eintrittskarten an Dritte ist nicht vorgesehen.
          Ich appelliere daher an Sie, das o.g. Inserat zu löschen.
          
          Mit freundlichen Grüßen
          Im Auftrag
          Dr. Prof. Sombody
        EOF
      end
      within(find(".v-input", text: "Link zur betroffenen Anzeige")) do
        fill_in "Link zur betroffenen Anzeige", with: "https://www.dsble.de/784406"
      end
      within(find(".v-input", text: "Text der betroffenen Anzeige")) do
        fill_in "Text der betroffenen Anzeige", with: "Hallo\nich biete 2 Eintrittskarten für die das Event am 04.12.2019 um 18.30 Uhr an."
      end
    end

    #     Schritt 9 (Aufgabe abschließen und Weiterleiten an Nutzer1)
    #
    # Da das Erfassen der Missbrauchsmeldung damit abgeschlossen, beendet der DSB-Nutzer die Aufgabe, wodurch
    # automatisch die Aufgabe “Entscheidung Löschen” gestartet wird. Diese Entscheidung soll “Nutzer1” treffen.
    within middle_area do
      assert has_text?("Missbrauchshinweis aufnehmen")
      click_on "Aufgabe abschließen"
      assert has_text?("Abgeschlossen")
    end
    within left_sidebar do
      next_task_in_sidebar = find(".v-list-item", text: "Entscheidung Löschung")
      assert next_task_in_sidebar.has_text?("Gestartet")
      next_task_in_sidebar.click
    end
    assert middle_area.has_text?("Entscheidung Löschung")
    within right_sidebar do
      within(control_for("Verantwortlicher")) do
        click_on "Ändern"
        fill_in "Suche", with: "no access"
        find(".v-list-item", text: "no_access_user@example.org").click
      end
      assert control_for("Verantwortlicher").has_text?("no_access_user@example.org")
    end

    comment_area = find_prosemirror_editor(page.find(".activity-hub"))
    prosemirror_fill_in(comment_area, "@no")
    page.find(".mention-suggestions-menu .v-list-item", text: "no_access_user@example.org").click
    prosemirror_fill_in(comment_area, "kannst Du bitte noch heute diese Entscheidung vornehmen. Danke.")
    click_button("Kommentieren")

    logout_using_menu

    # Schritt 10 (Nutzer1 trifft die Entscheidung, dass diese Anzeige gelöscht werden soll)
    #
    # Der Nutzer1 loggt sich wie jeden Tag einmal in das System ein. Dann wechselt er zu “my Tasks” und sieht,
    # dass die Aufgabe “Entscheidung Löschung” ihm zugewiese ist. Er geht zu dieser Aufgabe und trifft die Entscheidung,
    # dass die Anzeige gelöscht werden soll.
    login_using_form_with("no_access_user@example.org", "password")
    click_on("user-tasks-button")
    click_on("Entscheidung Löschung")

    tasks_and_process_visible = left_sidebar.all("a.v-list-item")
    assert_equal 2, tasks_and_process_visible.count # We may only see ONE task and the process as it's a private process

    within(middle_area) do
      click_on "Aufgabe abschließen"
      assert has_text?("Aufgabe kann erst abgeschlossen werden, wenn Daten vollständig eingegeben sind.")
      within(find(".v-input", text: "Deine kurze Begründung für die Entscheidung")) do
        fill_in "Deine kurze Begründung für die Entscheidung", with: "Offensichtlich ist es nicht gewünscht, dass diese Karten verkauft werden. Daher löschen wir die Anzeige."
      end
      within(find(".v-input", text: "Soll die Anzeige gelöscht werden?")) do
        click_on "Ja"
        has_text? "Ja" # wait until spinner disappears
      end
      click_on "Aufgabe abschließen"
      assert has_text?("Abgeschlossen")
    end
    logout_using_menu

    # Schritt 15 (Benachrichtigung sehen und zu nächster Aufgabe gehen)
    #
    # Später am Tag loggt sich DSB-Nutzer wieder ein. Er sieht in den Benachrichtigungen, dass die Aufgabe, die er
    # Nutzer1 zugewiesen hatte abgeschlossen wurde und die Aufgabe “Anzeige löschen” gestartet wurde.
    # Er wechselt in diese Aufgabe.
    login_using_form_with("dsb@uni-jena.example.org", "password")
    click_on("user-notifications-button")
    notification_on_finished_task = find(".v-timeline-item", text: /No Access User hat Aufgabe #\d+ • Entscheidung Löschung in Maßnahme %\d+ • Oper Leipzig abgeschlossen/)
    within(notification_on_finished_task) { click_on "Archivieren" }
    notification_delete_task = find(".v-timeline-item", text: /Aufgabe #\d+ • Anzeige löschen in Maßnahme %\d+ • Oper Leipzig wurde gestartet/)
    notification_delete_task.click_on "Anzeige löschen"
    # Wait until task page has loaded to avoid failing steps (link points to /task/xx and is redirected to /processes/xx/task/xx)
    assert page.has_css?(".page-task")

    # Schritt 16 (Anzeige Löschen und Dankes-Email-Schreiben)
    #
    # Er schließt die Maßnahme ab.
    within middle_area do
      assert has_text?("Anzeige löschen")
      assert find(".support-info-box", text: "https://www.dsble.de/784406")
      click_on "Aufgabe abschließen"
      assert has_text?("Abgeschlossen")
    end

    left_sidebar.click_on "Versendung Standard-Dankes-E-Mail"

    within middle_area do
      assert has_text?("Versendung Standard-Dankes-E-Mail")
      assert find(".support-info-box", text: "somebody@emailprovider.co.uk")
      assert find(".support-info-box", text: "Lieber Nutzer, danke für den Hinweis. Wir haben die Anzeige gelöscht. Viele Grüße")
      click_on "Aufgabe abschließen"
      assert has_text?("Abgeschlossen")
    end

    left_sidebar.click_on "DSB Meldung Missbrauch V1"
    assert middle_area.has_text?("Abgeschlossen")
  end
end
